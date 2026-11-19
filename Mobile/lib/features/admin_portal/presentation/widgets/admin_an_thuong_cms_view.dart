import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class AnThuongVendorSubmission {
  AnThuongVendorSubmission({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.category, // Food, Cafe, Nightlife, Performance
    required this.street,
    required this.openingHours,
    required this.phone,
    required this.description,
    required this.status, // PENDING, APPROVED, REJECTED
    required this.submittedDate,
  });

  final String id;
  final String businessName;
  final String ownerName;
  final String category;
  final String street;
  final String openingHours;
  final String phone;
  final String description;
  String status;
  final String submittedDate;
}

/// [FE-12 / Epic 2] Mở Rộng Khu Phố Du Lịch An Thượng & Phê Duyệt Địa Điểm Vendor
class AdminAnThuongCmsView extends StatefulWidget {
  const AdminAnThuongCmsView({super.key});

  @override
  State<AdminAnThuongCmsView> createState() => _AdminAnThuongCmsViewState();
}

class _AdminAnThuongCmsViewState extends State<AdminAnThuongCmsView> {
  String _activeTab = 'APPROVAL'; // APPROVAL or DIRECTORY or EVENTS
  String _categoryFilter = 'Tất cả';

  late final List<AnThuongVendorSubmission> _submissions = [
    AnThuongVendorSubmission(
      id: 'sub_1',
      businessName: 'The Craft Beer Pub & Lounge',
      ownerName: 'Nguyễn Văn Minh',
      category: 'Nightlife',
      street: 'Đường An Thượng 2, Mỹ An',
      openingHours: '16:00 - 02:00 sáng',
      phone: '0905 123 456',
      description: 'Quán pub phong cách mộc, phục vụ bia thủ công địa phương Đà Nẵng và nhạc Acoustic trực tiếp hàng đêm.',
      status: 'PENDING',
      submittedDate: '19/11/2026',
    ),
    AnThuongVendorSubmission(
      id: 'sub_2',
      businessName: 'Góc Cà Phê Hội An Cổ Điển',
      ownerName: 'Trần Thị Thu Thảo',
      category: 'Cafe',
      street: 'Đường An Thượng 4, Mỹ An',
      openingHours: '07:00 - 22:30',
      phone: '0912 345 678',
      description: 'Không gian đèn lồng Hội An, cà phê trứng và đặc sản bánh mì Hội An giòn tan.',
      status: 'PENDING',
      submittedDate: '18/11/2026',
    ),
    AnThuongVendorSubmission(
      id: 'sub_3',
      businessName: 'Mì Quảng Bếp Cụ Huỳnh',
      ownerName: 'Huỳnh Bá Đức',
      category: 'Food',
      street: 'Đường Ngô Thì Sĩ, Mỹ An',
      openingHours: '06:00 - 21:00',
      phone: '0934 567 890',
      description: 'Mì quảng tôm thịt truyền thống gia truyền 3 đời, phục vụ du khách trải nghiệm ẩm thực bản địa.',
      status: 'APPROVED',
      submittedDate: '15/11/2026',
    ),
    AnThuongVendorSubmission(
      id: 'sub_4',
      businessName: 'Sân Khấu Nghệ Thuật Đường Phố An Thượng Hub',
      ownerName: 'Ban Quản Lý Phố Đi Bộ',
      category: 'Performance',
      street: 'Ngã tư An Thượng 1 & Hoàng Kế Viêm',
      openingHours: '19:00 - 23:00 cuối tuần',
      phone: '0236 388 999',
      description: 'Sân khấu mở dành cho các ban nhạc trẻ, biểu diễn flashmob và ảo thuật đường phố phục vụ du khách.',
      status: 'APPROVED',
      submittedDate: '10/11/2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingCount = _submissions.where((s) => s.status == 'PENDING').length;

    return TourismCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mở Rộng Phố Đi Bộ An Thượng & Phê Duyệt Vendor (Epic 2)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quản lý 4 phân nhóm: Ẩm thực (Food), Cà phê (Cafe), Nightlife & Văn nghệ đường phố',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pendingCount > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: pendingCount > 0 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    Icon(
                      pendingCount > 0 ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                      size: 16,
                      color: pendingCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$pendingCount cơ sở chờ duyệt',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: pendingCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Tabs: Duyệt hồ sơ vendor vs Lịch sự kiện đêm ───────────────────
          Row(
            children: [
              _buildSubNavTab('Duyệt Hồ Sơ Vendor Gửi Lên ($pendingCount)', 'APPROVAL'),
              const SizedBox(width: 8),
              _buildSubNavTab('Danh Mục Cơ Sở Kinh Doanh Đã Lên Bản Đồ', 'DIRECTORY'),
              const SizedBox(width: 8),
              _buildSubNavTab('Lịch Văn Nghệ & Sự Kiện Đêm', 'EVENTS'),
            ],
          ),
          const SizedBox(height: 18),

          // ── Content Switcher ────────────────────────────────────────────────
          if (_activeTab == 'APPROVAL')
            _buildVendorApprovalTable()
          else if (_activeTab == 'DIRECTORY')
            _buildDirectoryView()
          else
            _buildNightlifeEventsView(),
        ],
      ),
    );
  }

  Widget _buildSubNavTab(String title, String tabKey) {
    final isSelected = _activeTab == tabKey;
    return ChoiceChip(
      label: Text(title),
      selected: isSelected,
      selectedColor: AppColors.primarySurface,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontSize: 13,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _activeTab = tabKey);
      },
    );
  }

  Widget _buildVendorApprovalTable() {
    final pendingList = _submissions.where((s) => s.status == 'PENDING').toList();

    if (pendingList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.task_alt_rounded, size: 40, color: Color(0xFF16A34A)),
              SizedBox(height: 10),
              Text('Tất cả hồ sơ đăng ký từ Vendor An Thượng đã được xử lý hoàn tất!', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: AppColors.border, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(2.8),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(2.2),
        3: FlexColumnWidth(1.6),
        4: FlexColumnWidth(2.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          children: [
            for (final h in ['Tên Cơ Sở & Chủ Hộ', 'Nhóm Dịch Vụ', 'Tuyến Tuyến Phố', 'Giờ Đêm', 'Hành Động Phê Duyệt'])
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
          ],
        ),
        for (final item in pendingList)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.businessName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('Chủ hộ: ${item.ownerName} • SĐT: ${item.phone}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(item.category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(item.street, style: const TextStyle(fontSize: 12.5)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(item.openingHours, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => item.status = 'APPROVED');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã phê duyệt ${item.businessName} lên bản đồ An Thượng!')),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Duyệt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () {
                        setState(() => item.status = 'REJECTED');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Từ chối'),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDirectoryView() {
    final approvedList = _submissions.where((s) => s.status == 'APPROVED').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Danh Mục Các Cơ Sở Đã Phê Duyệt:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const Spacer(),
            DropdownButton<String>(
              value: _categoryFilter,
              underline: const SizedBox(),
              items: ['Tất cả', 'Food', 'Cafe', 'Nightlife', 'Performance']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _categoryFilter = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final item in approvedList)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, size: 28, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.businessName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      Text('${item.category} • ${item.street} • Giờ mở: ${item.openingHours}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Đang hiển thị trên bản đồ', style: TextStyle(color: Color(0xFF15803D), fontSize: 11.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNightlifeEventsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Lịch Văn Nghệ, Biểu Diễn & Sự Kiện Đêm Phố Đi Bộ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('+ Thêm Sự Kiện Đêm'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final ev in [
          (title: 'Acoustic Sunset & Night Vibes', time: 'Mỗi Thứ 6 & Thứ 7 (20:00 - 22:30)', venue: 'Ngã tư An Thượng 2 & Hoàng Kế Viêm', band: 'Ban nhạc Flamenco Đà Nẵng'),
          (title: 'Carnival Vũ Điệu Đường Phố & Ẩm Thực Đêm', time: 'Chủ Nhật (19:30 - 22:00)', venue: 'Tuyến Phố An Thượng 1', band: 'Đoàn vũ công Quốc tế'),
          (title: 'Đêm Thơ Nhạc & Không Gian Trà Đạo', time: 'Thứ 4 hằng tuần (20:00 - 21:30)', venue: 'Không gian Văn hóa An Thượng 3', band: 'CLB Văn Nghệ Dân Gian'),
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.nightlife_rounded, size: 28, color: Color(0xFF7C3AED)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ev.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Thời gian: ${ev.time} | Địa điểm: ${ev.venue} | Biểu diễn: ${ev.band}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
              ],
            ),
          ),
      ],
    );
  }
}
