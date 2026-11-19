import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/tourism_components.dart';

/// [FE-17 / Epic 1 / Sheet gid=0] Dashboard Tổng quan Quản trị & Giám sát Chất lượng Dữ liệu NHS360.
class AdminDashboardOverviewView extends StatelessWidget {
  const AdminDashboardOverviewView({
    super.key,
    required this.onNavigateToTab,
  });

  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. KPI Metric Cards ──────────────────────────────────────────────
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1200 ? 6 : (width >= 800 ? 3 : 2);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: width >= 1200 ? 1.45 : 1.35,
              children: [
                _AdminKpiCard(
                  title: 'Tổng Điểm Đến',
                  value: '32',
                  delta: '+4 mới',
                  subtitle: '5 phân loại chuẩn',
                  icon: Icons.landscape_rounded,
                  color: AppColors.primary,
                ),
                _AdminKpiCard(
                  title: 'Độ Chuẩn Hóa Data',
                  value: '88.5%',
                  delta: '+12.4%',
                  subtitle: 'Theo chuẩn Epic 1',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF0D9488), // Teal
                ),
                _AdminKpiCard(
                  title: 'Lượt Xem VR360',
                  value: '35,420',
                  delta: '+24.1%',
                  subtitle: '6 tuyến di sản',
                  icon: Icons.threesixty_rounded,
                  color: const Color(0xFF2563EB), // Blue
                ),
                _AdminKpiCard(
                  title: 'Quét QR Check-in',
                  value: '18,650',
                  delta: '+18.7%',
                  subtitle: 'Geofence HMAC',
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFFD97706), // Amber
                ),
                _AdminKpiCard(
                  title: 'QR Sân Bay (Campaign)',
                  value: '6,890',
                  delta: '+42.5%',
                  subtitle: 'T1/T2 Đà Nẵng',
                  icon: Icons.flight_land_rounded,
                  color: const Color(0xFF7C3AED), // Purple
                ),
                _AdminKpiCard(
                  title: 'Vé Workshop Làng Đá',
                  value: '1,420',
                  delta: '+15.2%',
                  subtitle: '24 ca trải nghiệm',
                  icon: Icons.confirmation_number_rounded,
                  color: const Color(0xFFE11D48), // Rose
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // ── 2. Data Completeness & Quality Alert (Epic 1) ────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB), // Amber 50
            border: Border.all(color: const Color(0xFFFDE68A)), // Amber 200
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cảnh Báo Độ Đầy Đủ Dữ Liệu Du Lịch (Epic 1 - Data Completeness Quality)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hệ thống phát hiện 3 điểm đến chưa đạt chuẩn 100% dữ liệu (thiếu Audio Guide đa ngữ, thiếu ảnh VR360 hoặc thiếu thông tin trạm an toàn biển).',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFFB45309)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => onNavigateToTab(1), // Go to CMS Destinations tab
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Bổ Sung Ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB45309),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFFDE68A), height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _DataMissingChip(
                    destination: 'Vọng Hải Đài',
                    missingText: 'Thiếu Audio Guide (KO, ZH)',
                    onFix: () => onNavigateToTab(1),
                  ),
                  _DataMissingChip(
                    destination: 'Làng Đá Mỹ Nghệ Non Nước',
                    missingText: 'Thiếu ảnh VR360 Equirectangular',
                    onFix: () => onNavigateToTab(2),
                  ),
                  _DataMissingChip(
                    destination: 'Bãi Tắm Tân Trà',
                    missingText: 'Thiếu tọa độ Trạm Cứu Hộ Biển',
                    onFix: () => onNavigateToTab(4),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── 3. Monthly Engagement Visualizer ──────────────────────────────────
        TourismCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lưu Lượng Tham Quan, Quét QR & Tương Tác VR360 (Năm 2026)',
                        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dữ liệu tổng hợp từ các điểm di sản, phố đi bộ An Thượng, bãi biển và QR Sân bay',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text('12 Tháng / 2026 • Quận Ngũ Hành Sơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              // Simulated Chart Visualizer
              SizedBox(
                height: 190,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final m in [
                      (month: 'Thg 1', val: 0.48, label: '14.2k'),
                      (month: 'Thg 2', val: 0.78, label: '23.4k'),
                      (month: 'Thg 3', val: 0.92, label: '27.6k'),
                      (month: 'Thg 4', val: 0.70, label: '21.0k'),
                      (month: 'Thg 5', val: 0.62, label: '18.6k'),
                      (month: 'Thg 6', val: 0.88, label: '26.4k'),
                      (month: 'Thg 7', val: 1.00, label: '30.0k'),
                      (month: 'Thg 8', val: 0.95, label: '28.5k'),
                      (month: 'Thg 9', val: 0.65, label: '19.5k'),
                      (month: 'Thg 10', val: 0.75, label: '22.5k'),
                      (month: 'Thg 11', val: 0.85, label: '25.5k'),
                      (month: 'Thg 12', val: 0.90, label: '27.0k'),
                    ])
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(m.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 140 * m.val,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppColors.primaryDark, AppColors.primaryLight],
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(m.month, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── 4. Recent Audit Logs ──────────────────────────────────────────────
        TourismCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Nhật Ký Tác Vụ Gần Đây (Audit Logs - LI-07, FE-28)', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => onNavigateToTab(10), // Go to Audit Logs tab
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('Xem toàn bộ nhật ký'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final log in [
                (action: 'Cập nhật cảnh báo an toàn biển Tân Trà (Cờ Vàng - Sóng 1.2m)', user: 'taivdde180369@fpt.edu.vn (MANAGER)', time: '5 phút trước', status: 'SUCCESS'),
                (action: 'Phê duyệt 2 địa điểm ẩm thực phố An Thượng do Vendor gửi', user: 'buunnde180722@fpt.edu.vn (ADMIN)', time: '25 phút trước', status: 'SUCCESS'),
                (action: 'Tạo mã QR Campaign mới cho Sân bay Quốc tế Đà Nẵng T2', user: 'quangltn3@fe.edu.vn (ADMIN)', time: '1 giờ trước', status: 'SUCCESS'),
                (action: 'Gắn Audio Guide đa ngữ vào Hotspot Bia Ma Nhai Động Huyền Không', user: 'nganvmde180218@fpt.edu.vn (MANAGER)', time: '3 giờ trước', status: 'SUCCESS'),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF15803D)),
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

class _AdminKpiCard extends StatelessWidget {
  const _AdminKpiCard({
    required this.title,
    required this.value,
    required this.delta,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String delta;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 17, color: color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    delta,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataMissingChip extends StatelessWidget {
  const _DataMissingChip({
    required this.destination,
    required this.missingText,
    required this.onFix,
  });

  final String destination;
  final String missingText;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onFix,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 14, color: Color(0xFFD97706)),
            const SizedBox(width: 6),
            Text(
              destination,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
            ),
            const Text(' : ', style: TextStyle(color: Color(0xFFB45309))),
            Text(
              missingText,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFFD97706)),
          ],
        ),
      ),
    );
  }
}
