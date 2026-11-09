import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/tourism_buttons.dart';
import '../../../../shared/widgets/tourism_components.dart';

/// [360 Admin Web] Cổng Quản trị & CMS Du lịch Thông minh NHS360 (FE-17 -> FE-28).
/// Thiết kế chuẩn Enterprise Dashboard & Productivity First:
/// - Sidebar phân loại danh mục nghiệp vụ
/// - Topbar tra cứu, thông báo & hồ sơ người quản trị
/// - KPI Cards với biểu đồ xu hướng
/// - Bảng dữ liệu chi tiết, bộ lọc đa tiêu chí và trạng thái phân quyền RBAC
class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  final List<({String title, IconData icon, int category})> _navItems = [
    (title: 'Tổng quan Dashboard', icon: Icons.dashboard_rounded, category: 0),
    (title: 'Quản lý Điểm đến (CMS)', icon: Icons.landscape_rounded, category: 1),
    (title: 'VR360 & Audio Media', icon: Icons.threesixty_rounded, category: 1),
    (title: 'Sự kiện & Workshop', icon: Icons.event_rounded, category: 1),
    (title: 'Làng nghề & Nghệ nhân', icon: Icons.handyman_rounded, category: 1),
    (title: 'QR Check-in & Tích điểm', icon: Icons.qr_code_scanner_rounded, category: 2),
    (title: 'Kho Quà tặng & Voucher', icon: Icons.redeem_rounded, category: 2),
    (title: 'Đánh giá & Kiểm duyệt', icon: Icons.rate_review_rounded, category: 2),
    (title: 'Đặt chỗ & Tham gia', icon: Icons.confirmation_number_rounded, category: 2),
    (title: 'Chiến dịch Quảng bá', icon: Icons.campaign_rounded, category: 2),
    (title: 'Người dùng & Phân quyền', icon: Icons.manage_accounts_rounded, category: 3),
    (title: 'Audit Logs & Hệ thống', icon: Icons.security_rounded, category: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Row(
        children: [
          // ── 1. Admin Sidebar ─────────────────────────────────────────────────
          _AdminSidebar(
            selectedIndex: _selectedTab,
            navItems: _navItems,
            onSelect: (index) => setState(() => _selectedTab = index),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),

          // ── 2. Admin Main Content ───────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Topbar
                _AdminTopbar(
                  title: _navItems[_selectedTab].title,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                // Main Views Switcher
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildTabContent(_selectedTab),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _DashboardOverviewView();
      case 1:
        return _DestinationsCmsView(searchQuery: _searchQuery);
      case 2:
        return _VrAudioCmsView();
      case 3:
        return _EventsWorkshopsCmsView();
      case 5:
        return _QrCheckinRulesView();
      case 10:
        return _UsersRbacView();
      case 11:
        return _AuditLogsView();
      default:
        return _GenericModuleCmsView(title: _navItems[index].title);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR & TOPBAR
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<({String title, IconData icon, int category})> navItems;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NHS360 ADMIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Cổng Quản trị Du lịch',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          // Navigation List
          Expanded(
            child: ListView.separated(
              itemCount: navItems.length,
              separatorBuilder: (context, i) {
                if (i < navItems.length - 1 && navItems[i].category != navItems[i + 1].category) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: AppColors.border),
                  );
                }
                return const SizedBox(height: 2);
              },
              itemBuilder: (context, i) {
                final item = navItems[i];
                final isSelected = i == selectedIndex;
                return Material(
                  color: isSelected ? AppColors.primarySurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 19,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          // Exit button back to tourist app
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context.go(RouteNames.explore),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text(
                    'Về App Khám Phá',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTopbar extends StatelessWidget {
  const _AdminTopbar({
    required this.title,
    required this.onSearchChanged,
  });

  final String title;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          // Quick Search Box
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dữ liệu...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Role & Profile Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF15803D)),
                SizedBox(width: 4),
                Text(
                  'ROLE: ADMIN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text('AD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 1: DASHBOARD OVERVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardOverviewView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 KPI Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 1.7 : 1.4,
              children: const [
                _KpiMetricCard(
                  title: 'Tổng Du Khách',
                  value: '48,250',
                  delta: '+14.2%',
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
                _KpiMetricCard(
                  title: 'Lượt Xem VR360',
                  value: '29,480',
                  delta: '+22.5%',
                  icon: Icons.threesixty_rounded,
                  color: AppColors.secondary,
                ),
                _KpiMetricCard(
                  title: 'Quét QR Check-in',
                  value: '12,850',
                  delta: '+18.7%',
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.accent,
                ),
                _KpiMetricCard(
                  title: 'Đặt Chỗ Workshop',
                  value: '1,420',
                  delta: '+8.4%',
                  icon: Icons.confirmation_number_rounded,
                  color: Color(0xFF8B5CF6),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Quick Action Bar & Chart Simulation
        TourismCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Lưu Lượng Tham Quan & Check-in Theo Tháng (2026)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Năm 2026 • Quận Ngũ Hành Sơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Simulated Traffic Bar Graph
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final m in [
                      (month: 'T1', val: 0.45),
                      (month: 'T2', val: 0.75),
                      (month: 'T3', val: 0.90),
                      (month: 'T4', val: 0.65),
                      (month: 'T5', val: 0.55),
                      (month: 'T6', val: 0.85),
                      (month: 'T7', val: 1.00),
                      (month: 'T8', val: 0.92),
                      (month: 'T9', val: 0.60),
                      (month: 'T10', val: 0.70),
                      (month: 'T11', val: 0.82),
                      (month: 'T12', val: 0.88),
                    ])
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 32,
                            height: 140 * m.val,
                            decoration: BoxDecoration(
                              gradient: AppColors.oceanGradient,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(m.month, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent Audit Activity Log
        TourismCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhật Ký Tác Vụ Gần Đây (Audit Logs)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final log in [
                (action: 'Cập nhật điểm thưởng QR', user: 'buunnde180722@fpt.edu.vn', time: '10 phút trước', status: 'SUCCESS'),
                (action: 'Thêm ảnh VR360 Động Huyền Không', user: 'quangltn3@fe.edu.vn', time: '2 giờ trước', status: 'SUCCESS'),
                (action: 'Phê duyệt 12 đánh giá du khách', user: 'taivdde180369@fpt.edu.vn', time: '5 giờ trước', status: 'SUCCESS'),
                (action: 'Sao lưu dữ liệu Cloud Firestore', user: 'SYSTEM CRON', time: 'Hôm nay 03:00', status: 'SUCCESS'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      ),
                      Text(log.user, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 16),
                      Text(log.time, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  const _KpiMetricCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(width: 8),
              Text(delta, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 2: DESTINATIONS CMS
// ─────────────────────────────────────────────────────────────────────────────

class _DestinationsCmsView extends StatelessWidget {
  const _DestinationsCmsView({required this.searchQuery});
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final mockDestinations = [
      (id: 'dong_huyen_khong', name: 'Động Huyền Không', zone: 'Thủy Sơn', vr: true, audio: true, rating: 4.9, published: true),
      (id: 'chua_tam_thai', name: 'Chùa Tam Thai', zone: 'Thủy Sơn', vr: true, audio: true, rating: 4.8, published: true),
      (id: 'chua_linh_ung', name: 'Chùa Linh Ứng Non Nước', zone: 'Thủy Sơn', vr: true, audio: true, rating: 4.9, published: true),
      (id: 'lang_da_non_nuoc', name: 'Làng Đá Mỹ Nghệ Non Nước', zone: 'Non Nước', vr: false, audio: true, rating: 4.7, published: true),
      (id: 'vong_hai_dai', name: 'Vọng Hải Đài', zone: 'Thủy Sơn', vr: true, audio: false, rating: 4.6, published: true),
      (id: 'dong_am_phu', name: 'Động Âm Phủ', zone: 'Thủy Sơn', vr: false, audio: true, rating: 4.8, published: true),
      (id: 'bien_son_thuy', name: 'Bãi Biển Sơn Thủy – Tân Trà', zone: 'Biển Non Nước', vr: true, audio: false, rating: 4.7, published: true),
      (id: 'pho_an_thuong', name: 'Khu Phố Du Lịch An Thượng', zone: 'An Thượng', vr: false, audio: true, rating: 4.6, published: true),
    ];

    final filtered = mockDestinations.where((d) => d.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Danh Mục Điểm Đến (FE-17)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm Điểm Đến Mới'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Data Table
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Tên Danh Thắng', 'Phân Vùng', 'VR360', 'Audio', 'Đánh Giá', 'Hành Động'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                ],
              ),
              for (final d in filtered)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(d.zone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(d.vr ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 18, color: d.vr ? AppColors.success : AppColors.textMuted),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(d.audio ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 18, color: d.audio ? AppColors.success : AppColors.textMuted),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('★ ${d.rating}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFF59E0B))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 3: VR / AUDIO MEDIA CMS
// ─────────────────────────────────────────────────────────────────────────────

class _VrAudioCmsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Kho Media VR360 & Thuyết Minh Audio (FE-18)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Tải Lên File Media'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Hỗ trợ định dạng ảnh Panorama 360° Equirectangular (tỷ lệ 2:1) và file âm thanh nén AAC/MP3 đa ngôn ngữ (vi, en, ko, zh) với Cloud Storage.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          for (final m in [
            (title: 'dong_huyen_khong_panorama.jpg', type: 'VR360 Image', size: '4.8 MB', res: '8192 x 4096'),
            (title: 'linh_ung_main_courtyard_vr.jpg', type: 'VR360 Image', size: '5.2 MB', res: '8192 x 4096'),
            (title: 'audio_huyen_khong_vi.mp3', type: 'Audio Guide (VI)', size: '2.4 MB', res: '4 phút 30 giây'),
            (title: 'audio_huyen_khong_en.mp3', type: 'Audio Guide (EN)', size: '2.5 MB', res: '4 phút 15 giây'),
            (title: 'audio_huyen_khong_ko.mp3', type: 'Audio Guide (KO)', size: '2.6 MB', res: '4 phút 40 giây'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(m.type.contains('VR') ? Icons.view_in_ar_rounded : Icons.headphones_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text('${m.type} • ${m.size} • ${m.res}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Chip(label: Text('Đang phát sóng', style: TextStyle(fontSize: 11, color: AppColors.success))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 4: EVENTS & WORKSHOPS CMS
// ─────────────────────────────────────────────────────────────────────────────

class _EventsWorkshopsCmsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Quản Lý Sự Kiện & Workshop Làng Nghề (FE-19)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tạo Sự Kiện / Workshop'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final ev in [
            (name: 'Workshop Chạm Khắc Tượng Chibi Đá', date: 'Mỗi Thứ 7 & CN', capacity: 25, booked: 18, artisan: 'Lê Triều'),
            (name: 'Lễ Hội Quán Thế Âm Ngũ Hành Sơn 2027', date: '19/02 Âm Lịch', capacity: 500, booked: 320, artisan: 'Ban Trị Sự'),
            (name: 'Cuộc Thi Điêu Khắc Tác Phẩm Non Nước', date: '25/08/2026', capacity: 50, booked: 42, artisan: 'Hội Mỹ Nghệ'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 28, color: AppColors.accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ev.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text('Thời gian: ${ev.date} | Người hướng dẫn: ${ev.artisan}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text('Đã đặt: ${ev.booked}/${ev.capacity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(width: 16),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 5: QR CHECK-IN RULES
// ─────────────────────────────────────────────────────────────────────────────

class _QrCheckinRulesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quy Tắc Quét QR Check-in & Tích Điểm (FE-20, LI-08)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Hệ thống chống gian lận kiểm tra chữ ký HMAC bí mật, xác thực bán kính GPS Geofence (tối đa 150m) và giới hạn giãn cách 60 phút giữa hai lần quét.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          for (final q in [
            (loc: 'Đỉnh Thượng Thai – Động Huyền Không', points: '+50 điểm', radius: '100m', hash: 'HMAC_SHA256_ACTIVE'),
            (loc: 'Bảo Tháp Xá Lợi – Chùa Linh Ứng', points: '+30 điểm', radius: '80m', hash: 'HMAC_SHA256_ACTIVE'),
            (loc: 'Cổng Làng Đá Mỹ Nghệ Non Nước', points: '+40 điểm', radius: '150m', hash: 'HMAC_SHA256_ACTIVE'),
            (loc: 'Khu Di Tích Ma Nhai UNESCO', points: '+60 điểm', radius: '80m', hash: 'HMAC_SHA256_ACTIVE'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.loc, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text('Geofence: ${q.radius} • Chữ ký: ${q.hash}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(q.points, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.success)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 6: USERS & RBAC
// ─────────────────────────────────────────────────────────────────────────────

class _UsersRbacView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = [
      (email: 'buunnde180722@fpt.edu.vn', name: 'Nguyễn Ngọc Bữu', role: 'ADMIN', active: true),
      (email: 'quangltn3@fe.edu.vn', name: 'Lê Thiện Nhật Quang', role: 'ADMIN', active: true),
      (email: 'taivdde180369@fpt.edu.vn', name: 'Văn Đức Tài', role: 'TOURISM_MANAGER', active: true),
      (email: 'nganvmde180218@fpt.edu.vn', name: 'Vương Mai Ngân', role: 'TOURISM_MANAGER', active: true),
      (email: 'tourist.demo@fe.edu.vn', name: 'Du Khách Trải Nghiệm', role: 'TOURIST', active: true),
    ];

    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Phân Quyền Vai Trò Người Dùng (FE-26, FE-27)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Thêm Tài Khoản'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Họ và Tên', 'Email', 'Vai Trò (Role)', 'Trạng Thái'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                ],
              ),
              for (final u in users)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.email, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.role, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: u.role == 'ADMIN' ? AppColors.error : AppColors.primary)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Đang hoạt động', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW 7: AUDIT LOGS & SYSTEM
// ─────────────────────────────────────────────────────────────────────────────

class _AuditLogsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cấu Hình Hệ Thống & Audit Logs (FE-28)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.backup_rounded, size: 18),
                label: const Text('Sao Lưu Dữ Liệu Ngay (Backup)'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_rounded, size: 18),
                label: const Text('Xuất Báo Cáo JSON/CSV'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Lịch sử sao lưu tự động:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          for (final b in [
            'backup_firestore_2026_11_09_0300.tar.gz (68 MB) - Hoàn tất',
            'backup_firestore_2026_11_08_0300.tar.gz (66 MB) - Hoàn tất',
            'backup_firestore_2026_11_07_0300.tar.gz (65 MB) - Hoàn tất',
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(b, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GenericModuleCmsView extends StatelessWidget {
  const _GenericModuleCmsView({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.construction_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Module quản trị đang kết nối với Cloud Functions & Firestore theo đặc tả FE-17 -> FE-28.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
