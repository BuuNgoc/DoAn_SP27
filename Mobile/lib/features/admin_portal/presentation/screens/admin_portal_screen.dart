import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/route_names.dart';

// Modular Web Admin Views
import '../widgets/admin_ai_analytics_view.dart';
import '../widgets/admin_an_thuong_cms_view.dart';
import '../widgets/admin_audit_system_view.dart';
import '../widgets/admin_beach_tourism_cms_view.dart';
import '../widgets/admin_campaign_analytics_cms_view.dart';
import '../widgets/admin_dashboard_overview_view.dart';
import '../widgets/admin_destinations_cms_view.dart';
import '../widgets/admin_stone_contest_cms_view.dart';
import '../widgets/admin_users_rbac_view.dart';
import '../widgets/admin_vr_hotspot_cms_view.dart';
import '../widgets/admin_workshops_cms_view.dart';

/// [360 Admin Web / CMS Portal] Cổng Quản trị & Điều Hành Du Lịch Thông Minh NHS360 Trên Trình Duyệt Web (FE-17 -> FE-28).
///
/// Thiết kế chuyên biệt cho nền tảng Website Desktop Browser:
/// - Sidebar phân cấp nghiệp vụ theo 4 nhóm chuyên môn (Dữ liệu di sản, Mở rộng vùng, Làng nghề & workshop, AI & Quản trị hệ thống)
/// - Topbar tra cứu, giám sát vai trò RBAC & định danh người quản trị
/// - 11 module quản trị độc lập tương ứng trọn vẹn với Epics 1 -> 8 từ Google Sheet
class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  final List<({String title, IconData icon, int category, String badge})> _navItems = [
    // Nhóm 0: TỔNG QUAN & DỮ LIỆU CỐT LÕI (Epic 1, 4)
    (title: 'Tổng quan Dashboard', icon: Icons.dashboard_rounded, category: 0, badge: ''),
    (title: 'Quản lý Điểm đến (CMS)', icon: Icons.landscape_rounded, category: 0, badge: 'Epic 1'),
    (title: 'VR360 & Hotspot Builder', icon: Icons.threesixty_rounded, category: 0, badge: 'Epic 4'),

    // Nhóm 1: MỞ RỘNG VÙNG & DU LỊCH BIỂN (Epic 2, 3)
    (title: 'Mở rộng Phố An Thượng', icon: Icons.nightlife_rounded, category: 1, badge: 'Epic 2'),
    (title: 'Du lịch Biển & Cảnh báo', icon: Icons.beach_access_rounded, category: 1, badge: 'Epic 3'),

    // Nhóm 2: LÀNG NGHỀ, WORKSHOP & TRUYỀN THÔNG (Epic 6, 7, 8)
    (title: 'Cuộc thi Điêu khắc Đá', icon: Icons.emoji_events_rounded, category: 2, badge: 'Epic 6'),
    (title: 'Workshop & Vé QR Check-in', icon: Icons.confirmation_number_rounded, category: 2, badge: 'Epic 7'),
    (title: 'Chiến dịch QR & Sân bay', icon: Icons.campaign_rounded, category: 2, badge: 'Epic 8'),

    // Nhóm 3: TRÍ TUỆ NHÂN TẠO & HỆ THỐNG (Epic 5, FE-26..28)
    (title: 'Thống kê AI Nhận diện Ảnh', icon: Icons.center_focus_strong_rounded, category: 3, badge: 'Epic 5'),
    (title: 'Người dùng & Phân quyền', icon: Icons.manage_accounts_rounded, category: 3, badge: 'RBAC'),
    (title: 'Audit Logs & Sao lưu', icon: Icons.security_rounded, category: 3, badge: 'FE-28'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 Desktop Background
      body: Row(
        children: [
          // ── 1. Admin Desktop Sidebar ─────────────────────────────────────────
          _AdminSidebar(
            selectedIndex: _selectedTab,
            navItems: _navItems,
            onSelect: (index) => setState(() => _selectedTab = index),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),

          // ── 2. Admin Desktop Main Workspace ─────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Topbar
                _AdminTopbar(
                  title: _navItems[_selectedTab].title,
                  badge: _navItems[_selectedTab].badge,
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
        return AdminDashboardOverviewView(
          onNavigateToTab: (targetIndex) => setState(() => _selectedTab = targetIndex),
        );
      case 1:
        return AdminDestinationsCmsView(searchQuery: _searchQuery);
      case 2:
        return const AdminVrHotspotCmsView();
      case 3:
        return const AdminAnThuongCmsView();
      case 4:
        return const AdminBeachTourismCmsView();
      case 5:
        return const AdminStoneContestCmsView();
      case 6:
        return const AdminWorkshopsCmsView();
      case 7:
        return const AdminCampaignAnalyticsCmsView();
      case 8:
        return const AdminAiAnalyticsView();
      case 9:
        return const AdminUsersRbacView();
      case 10:
        return const AdminAuditSystemView();
      default:
        return AdminDashboardOverviewView(
          onNavigateToTab: (targetIndex) => setState(() => _selectedTab = targetIndex),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR & TOPBAR FOR WEBSITE ADMIN PORTAL
// ─────────────────────────────────────────────────────────────────────────────

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<({String title, IconData icon, int category, String badge})> navItems;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding Web
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NHS360 WEB CMS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Hệ Thống Quản Trị Du Lịch',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Navigation List
          Expanded(
            child: ListView.separated(
              itemCount: navItems.length,
              separatorBuilder: (context, i) {
                if (i < navItems.length - 1 && navItems[i].category != navItems[i + 1].category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 6),
                        Text(
                          _getCategoryTitle(navItems[i + 1].category),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox(height: 2);
              },
              itemBuilder: (context, i) {
                final item = navItems[i];
                final isSelected = i == selectedIndex;
                return Material(
                  color: isSelected ? AppColors.primarySurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onSelect(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
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
                          if (item.badge.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
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
          const SizedBox(height: 10),

          // Switcher / Exit to tourist app
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.go(RouteNames.explore),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.travel_explore_rounded, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text(
                    'Xem Giao Diện Khám Phá',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle(int category) {
    switch (category) {
      case 1:
        return 'MỞ RỘNG VÙNG & BIỂN';
      case 2:
        return 'LÀNG NGHỀ, WORKSHOP & TRUYỀN THÔNG';
      case 3:
        return 'TRÍ TUỆ NHÂN TẠO & HỆ THỐNG';
      default:
        return 'DỮ LIỆU CỐT LÕI';
    }
  }
}

class _AdminTopbar extends StatelessWidget {
  const _AdminTopbar({
    required this.title,
    required this.badge,
    required this.onSearchChanged,
  });

  final String title;
  final String badge;
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
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          if (badge.isNotEmpty) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ),
          ],
          const Spacer(),

          // Quick Search Box on Web
          SizedBox(
            width: 280,
            height: 38,
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dữ liệu CMS...',
                hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
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

          // Environment & Port indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language_rounded, size: 14, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'PORT 8000 (WEB)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
