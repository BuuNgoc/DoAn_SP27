import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class QrCampaignItem {
  QrCampaignItem({
    required this.id,
    required this.name,
    required this.channelLocation,
    required this.targetLanding,
    required this.scans,
    required this.checkins,
    required this.shares,
    required this.conversionRate,
    required this.status,
  });

  final String id;
  final String name;
  final String channelLocation;
  final String targetLanding;
  int scans;
  int checkins;
  int shares;
  double conversionRate;
  String status;
}

/// [FE-14, FE-24 / Epic 8] Quản Trị Chiến Dịch QR Sân Bay & Thống Kê Lan Tỏa Truyền Thông
class AdminCampaignAnalyticsCmsView extends StatefulWidget {
  const AdminCampaignAnalyticsCmsView({super.key});

  @override
  State<AdminCampaignAnalyticsCmsView> createState() => _AdminCampaignAnalyticsCmsViewState();
}

class _AdminCampaignAnalyticsCmsViewState extends State<AdminCampaignAnalyticsCmsView> {
  late final List<QrCampaignItem> _campaigns = [
    QrCampaignItem(
      id: 'camp_airport_t1',
      name: 'Chiến Dịch Ga Đến Quốc Nội Sân Bay Đà Nẵng (T1)',
      channelLocation: 'Băng chuyền hành lý số 2 & Cửa ra Ga Quốc Nội T1',
      targetLanding: '/welcome-airport?campaign=airport_t1&route=4hours',
      scans: 3840,
      checkins: 1620,
      shares: 680,
      conversionRate: 42.1,
      status: 'ACTIVE',
    ),
    QrCampaignItem(
      id: 'camp_airport_t2',
      name: 'Chiến Dịch Ga Quốc Tế Sân Bay Đà Nẵng (T2)',
      channelLocation: 'Quầy thông tin du lịch Danang Fantasticity (Ga T2)',
      targetLanding: '/welcome-airport?campaign=airport_t2&lang=en',
      scans: 2450,
      checkins: 980,
      shares: 510,
      conversionRate: 40.0,
      status: 'ACTIVE',
    ),
    QrCampaignItem(
      id: 'camp_train_station',
      name: 'Chiến Dịch Ga Tàu Hỏa Đà Nẵng',
      channelLocation: 'Sảnh chờ vé trung tâm Ga Đà Nẵng',
      targetLanding: '/welcome-airport?campaign=train_station',
      scans: 890,
      checkins: 320,
      shares: 140,
      conversionRate: 35.9,
      status: 'ACTIVE',
    ),
    QrCampaignItem(
      id: 'camp_beach_hotel',
      name: 'QR Standee Chuỗi Khách Sạn & Resort Ven Biển',
      channelLocation: 'Lobby & Thang máy 15 khách sạn đối tác Sơn Thủy - Tân Trà',
      targetLanding: '/zones/beach?promo=hotel_stay',
      scans: 1540,
      checkins: 790,
      shares: 420,
      conversionRate: 51.2,
      status: 'ACTIVE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final totalScans = _campaigns.fold<int>(0, (sum, c) => sum + c.scans);
    final totalCheckins = _campaigns.fold<int>(0, (sum, c) => sum + c.checkins);
    final totalShares = _campaigns.fold<int>(0, (sum, c) => sum + c.shares);

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
                    'Chiến Dịch QR Sân Bay & Phân Tích Lan Tỏa Truyền Thông (FE-24, Epic 8)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quản lý mã QR đặt tại Sân bay Đà Nẵng T1/T2, nhà ga; cấu hình Landing Page và theo dõi tỷ lệ chuyển đổi',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openCreateCampaignDialog(context),
                icon: const Icon(Icons.qr_code_rounded, size: 18),
                label: const Text('+ Tạo Chiến Dịch QR Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Analytics Badges ────────────────────────────────────────────────
          Row(
            children: [
              _buildCampaignStat('Tổng Quét QR', '$totalScans lượt', Icons.qr_code_scanner_rounded, AppColors.primary),
              const SizedBox(width: 14),
              _buildCampaignStat('Check-in Thực Địa', '$totalCheckins lượt', Icons.place_rounded, const Color(0xFF16A34A)),
              const SizedBox(width: 14),
              _buildCampaignStat('Chia Sẻ Mạng Xã Hội', '$totalShares lượt share', Icons.share_rounded, const Color(0xFF2563EB)),
              const SizedBox(width: 14),
              _buildCampaignStat('Tỷ Lệ Chuyển Đổi TB', '43.2%', Icons.trending_up_rounded, const Color(0xFFD97706)),
            ],
          ),
          const SizedBox(height: 24),

          // ── Airport Landing Page Quick Preview Card ─────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Blue 50
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flight_land_rounded, size: 32, color: Color(0xFF2563EB)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Landing Page Đón Khách Sân Bay Đà Nẵng (Airport Arrival Hub)',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E40AF)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Thông điệp: "Chào mừng bạn đến Đà Nẵng! Khám phá Di sản Ngũ Hành Sơn nhanh trong 4 giờ" • Hỗ trợ đa ngữ: VI, EN, KO, ZH.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_suggest_rounded, size: 16),
                  label: const Text('Cấu Hình Landing Page'),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Campaigns Table ─────────────────────────────────────────────────
          const Text('Danh Sách Chiến Dịch QR & Điểm Chạm Du Khách:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(3.0),
              1: FlexColumnWidth(2.6),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Chiến Dịch & Vị Trí Đặt QR', 'Đường Dẫn Landing Page', 'Lượt Quét', 'Check-in', 'Lượt Share', 'Chuyển Đổi'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final c in _campaigns)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          Text(c.channelLocation, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(c.targetLanding, style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontFamily: 'monospace')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${c.scans}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${c.checkins}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF16A34A))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${c.shares}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2563EB))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          '${c.conversionRate}%',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF15803D)),
                        ),
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

  Widget _buildCampaignStat(String title, String value, IconData icon, Color color) {
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
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  void _openCreateCampaignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Chiến Dịch Mã QR Mới (FE-24)'),
        content: const SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Tên Chiến Dịch*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Vị Trí Đặt Standee / Poster QR*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Đường Dẫn Đích (Deep Link / Landing Page)*', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Tạo Mã QR'),
          ),
        ],
      ),
    );
  }
}
