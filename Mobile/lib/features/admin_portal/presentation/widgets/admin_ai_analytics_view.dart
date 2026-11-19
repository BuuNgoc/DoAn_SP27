import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

/// [FE-05 / Epic 5] Thống Kê & Phân Tích Mô Hình AI Nhận Diện Ảnh Địa Danh (AI Photo Recognition CMS)
class AdminAiAnalyticsView extends StatelessWidget {
  const AdminAiAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Thống Kê Mô Hình AI Nhận Diện Địa Danh (FE-05, Epic 5)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Báo cáo các điểm đến được nhận diện nhiều nhất, độ chính xác phân loại & tỷ lệ kích hoạt gợi ý Check-in / Workshop',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF15803D)),
                    SizedBox(width: 4),
                    Text('Model Status: ONLINE (SE13-ResNet50-V2)', style: TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── AI Health Metrics ───────────────────────────────────────────────
          Row(
            children: [
              _buildAiMetric('Độ Chính Xác (Accuracy)', '96.8%', Icons.auto_awesome_rounded, const Color(0xFF7C3AED)),
              const SizedBox(width: 14),
              _buildAiMetric('Thời Gian Xử Lý (Latency)', '285 ms', Icons.speed_rounded, const Color(0xFF0D9488)),
              const SizedBox(width: 14),
              _buildAiMetric('Tổng Ảnh Đã Quét', '14,890', Icons.image_search_rounded, const Color(0xFF2563EB)),
              const SizedBox(width: 14),
              _buildAiMetric('Gợi Ý Check-in Tự Động', '89.4%', Icons.check_circle_outline_rounded, const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Top Recognized Spots ────────────────────────────────────────────
          const Text('Top Địa Danh Được Du Khách Chụp Ảnh & Nhận Diện Nhiều Nhất (Epic 5):', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(1.0),
              1: FlexColumnWidth(3.0),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.8),
              4: FlexColumnWidth(2.0),
              5: FlexColumnWidth(2.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Hạng', 'Tên Danh Thắng / Di Tích', 'Lượt Nhận Diện', 'Độ Chính Xác', 'Gợi Ý Check-in', 'Workshop / Sản Phẩm Gợi Ý'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final s in [
                (rank: '#1', name: 'Động Huyền Không (Vòm Trời)', scans: '4,620 lượt', acc: '98.5%', checkin: '4,150 (89.8%)', ws: 'Tour Tâm Linh & Ma Nhai'),
                (rank: '#2', name: 'Chùa Linh Ứng Non Nước', scans: '3,840 lượt', acc: '97.2%', checkin: '3,380 (88.0%)', ws: 'Vòng Tay Cẩm Thạch'),
                (rank: '#3', name: 'Cổng Làng Đá Mỹ Nghệ Non Nước', scans: '2,950 lượt', acc: '96.1%', checkin: '2,710 (91.8%)', ws: 'Workshop Đục Đẽo Đá Chibi'),
                (rank: '#4', name: 'Vọng Hải Đài (Đỉnh Thủy Sơn)', scans: '2,140 lượt', acc: '95.4%', checkin: '1,890 (88.3%)', ws: 'Tuyến Di Sản Thủy Sơn'),
                (rank: '#5', name: 'Động Âm Phủ & Cầu Âm Dương', scans: '1,340 lượt', acc: '94.8%', checkin: '1,120 (83.5%)', ws: 'Khám Phá Hang Động 360'),
              ])
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.rank, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD97706)))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.scans, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.acc, style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w800, fontSize: 12.5))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.checkin, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s.ws, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Dataset Training & Synchronization Action ───────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.dataset_rounded, size: 28, color: AppColors.primary),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quản Lý Nhãn Huấn Luyện Dataset (18 Lớp Đối Tượng Ngũ Hành Sơn)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('Liên kết dịch vụ AI_Service/train_model.py • Dữ liệu ảnh thực tế tại các điểm danh thắng', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text('Đồng Bộ Dataset Mới'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
