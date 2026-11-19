import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class SystemAuditLog {
  SystemAuditLog({
    required this.id,
    required this.action,
    required this.module,
    required this.user,
    required this.ipAddress,
    required this.timestamp,
    required this.status,
  });

  final String id;
  final String action;
  final String module;
  final String user;
  final String ipAddress;
  final String timestamp;
  final String status;
}

/// [FE-28 / LI-07] Nhật Ký Kiểm Toán (Audit Logs) & Sao Lưu Dữ Liệu Hệ Thống (Website Admin)
class AdminAuditSystemView extends StatefulWidget {
  const AdminAuditSystemView({super.key});

  @override
  State<AdminAuditSystemView> createState() => _AdminAuditSystemViewState();
}

class _AdminAuditSystemViewState extends State<AdminAuditSystemView> {
  late final List<SystemAuditLog> _logs = [
    SystemAuditLog(
      id: 'log_101',
      action: 'Cập nhật cờ cảnh báo an toàn bờ biển Tân Trà (YELLOW)',
      module: 'Beach Tourism CMS',
      user: 'taivdde180369@fpt.edu.vn',
      ipAddress: '113.160.224.18',
      timestamp: '19/11/2026 19:42:15',
      status: 'SUCCESS',
    ),
    SystemAuditLog(
      id: 'log_102',
      action: 'Phê duyệt 2 địa điểm vendor phố An Thượng lên bản đồ',
      module: 'An Thuong CMS',
      user: 'buunnde180722@fpt.edu.vn',
      ipAddress: '14.162.145.89',
      timestamp: '19/11/2026 19:15:02',
      status: 'SUCCESS',
    ),
    SystemAuditLog(
      id: 'log_103',
      action: 'Tạo mã QR Campaign mới cho Ga Quốc Tế Sân Bay Đà Nẵng T2',
      module: 'Campaign QR',
      user: 'quangltn3@fe.edu.vn',
      ipAddress: '118.69.182.5',
      timestamp: '19/11/2026 18:30:44',
      status: 'SUCCESS',
    ),
    SystemAuditLog(
      id: 'log_104',
      action: 'Gắn Audio Guide thuyết minh đa ngữ vào Hotspot Bia Ma Nhai',
      module: 'VR360 Hotspot',
      user: 'nganvmde180218@fpt.edu.vn',
      ipAddress: '113.161.72.102',
      timestamp: '19/11/2026 16:55:18',
      status: 'SUCCESS',
    ),
    SystemAuditLog(
      id: 'log_105',
      action: 'Sao lưu tự động toàn bộ cơ sở dữ liệu Cloud Firestore (CRON)',
      module: 'Database Backup',
      user: 'SYSTEM CRON',
      ipAddress: '10.0.0.1 (Internal)',
      timestamp: '19/11/2026 03:00:00',
      status: 'SUCCESS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TourismCard(
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
                    'Nhật Ký Kiểm Toán & Sao Lưu Hệ Thống (FE-28, LI-07)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ghi nhận toàn bộ thao tác thêm, sửa, xóa dữ liệu CMS; quản lý bản sao lưu Firestore an toàn',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang tiến hành sao lưu toàn bộ Cloud Firestore... Hoàn tất!')),
                  );
                },
                icon: const Icon(Icons.backup_rounded, size: 18),
                label: const Text('Sao Lưu Cơ Sở Dữ Liệu Ngay'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xuất báo cáo Audit Logs định dạng CSV thành công!')),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Xuất CSV / JSON'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Logs Table
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(3.8),
              2: FlexColumnWidth(2.0),
              3: FlexColumnWidth(2.6),
              4: FlexColumnWidth(1.8),
              5: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Thời Gian', 'Hành Động Tác Vụ', 'Phân Hệ', 'Tài Khoản Thực Hiện', 'Địa Chỉ IP', 'Kết Quả'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final l in _logs)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l.timestamp, style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l.module, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l.user, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(l.ipAddress, style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: AppColors.textMuted)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                        child: Text(l.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
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
