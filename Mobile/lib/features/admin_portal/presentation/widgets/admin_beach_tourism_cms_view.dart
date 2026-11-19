import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class BeachSafetyNotice {
  BeachSafetyNotice({
    required this.beachId,
    required this.beachName,
    required this.flagColor, // 'GREEN', 'YELLOW', 'RED'
    required this.waveHeight,
    required this.windSpeed,
    required this.lifeguardStatus,
    required this.ripCurrentWarning,
    required this.noticeMessage,
    required this.updatedAt,
  });

  final String beachId;
  final String beachName;
  String flagColor;
  String waveHeight;
  String windSpeed;
  String lifeguardStatus;
  bool ripCurrentWarning;
  String noticeMessage;
  String updatedAt;
}

/// [FE-13 / Epic 3] Quản Trị Du Lịch Biển Sơn Thủy - Tân Trà & Cảnh Báo An Toàn Biển
class AdminBeachTourismCmsView extends StatefulWidget {
  const AdminBeachTourismCmsView({super.key});

  @override
  State<AdminBeachTourismCmsView> createState() => _AdminBeachTourismCmsViewState();
}

class _AdminBeachTourismCmsViewState extends State<AdminBeachTourismCmsView> {
  late final List<BeachSafetyNotice> _beaches = [
    BeachSafetyNotice(
      beachId: 'beach_son_thuy',
      beachName: 'Bãi Tắm Sơn Thủy',
      flagColor: 'GREEN',
      waveHeight: '0.5 - 0.8m',
      windSpeed: 'Cấp 2 - 3 (Gió nhẹ)',
      lifeguardStatus: 'Đang trực cứu hộ (05:00 - 18:30)',
      ripCurrentWarning: false,
      noticeMessage: 'Thời tiết biển êm dịu, an toàn tuyệt đối cho du khách tắm biển và tham gia thể thao dưới nước trong khu vực giăng phao.',
      updatedAt: 'Hôm nay 08:30',
    ),
    BeachSafetyNotice(
      beachId: 'beach_tan_tra',
      beachName: 'Bãi Tắm Tân Trà',
      flagColor: 'YELLOW',
      waveHeight: '1.0 - 1.4m',
      windSpeed: 'Cấp 4 (Gió vừa)',
      lifeguardStatus: 'Đang trực cứu hộ (05:00 - 18:30)',
      ripCurrentWarning: true,
      noticeMessage: 'Biển động nhẹ. Chú ý: Xuất hiện dòng nước rút (rip current) tại khu vực mũi đá phía nam. Du khách vui lòng chỉ tắm trong khu vực cờ hiệu quy định.',
      updatedAt: 'Hôm nay 09:15',
    ),
    BeachSafetyNotice(
      beachId: 'beach_non_nuoc_resort',
      beachName: 'Bãi Biển Ven Khu Resort Non Nước',
      flagColor: 'GREEN',
      waveHeight: '0.6 - 0.9m',
      windSpeed: 'Cấp 3',
      lifeguardStatus: 'Cứu hộ phối hợp Resort trực',
      ripCurrentWarning: false,
      noticeMessage: 'Bãi tắm sạch đẹp, dịch vụ dù ghế và cano thể thao biển hoạt động bình thường.',
      updatedAt: 'Hôm nay 07:00',
    ),
  ];

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
                    'Du Lịch Biển & Hệ Thống Cảnh Báo An Toàn Bờ Biển (FE-13, Epic 3)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quản lý bãi tắm Sơn Thủy, Tân Trà, lối xuống biển, trạm cứu hộ & cập nhật cờ cảnh báo an toàn thời gian thực',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openEmergencyBroadcastDialog(context),
                icon: const Icon(Icons.campaign_rounded, size: 18),
                label: const Text('Phát Cảnh Báo Khẩn Cấp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Real-time Beach Safety Cards ────────────────────────────────────
          const Text('Tình Trạng An Toàn & Cờ Hiệu Bờ Biển Hiện Tại:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          for (final b in _beaches)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _flagBorderColor(b.flagColor), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _flagColorValue(b.flagColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _flagLabel(b.flagColor),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(b.beachName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      if (b.ripCurrentWarning) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: const Text('Cảnh Báo Dòng Nước Rút (Rip Current)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                        ),
                      ],
                      const Spacer(),
                      Text('Cập nhật: ${b.updatedAt}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openUpdateSafetyDialog(context, b),
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text('Đổi Cờ & Cập Nhật'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(b.noticeMessage, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Sóng biển: ${b.waveHeight}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      Text('Gió: ${b.windSpeed}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      Text('Lực lượng cứu hộ: ${b.lifeguardStatus}', style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // ── Beach Infrastructure & Resort Linkage ───────────────────────────
          const Text('Hạ Tầng Tiện Ích Biển & Khách Sạn Gợi Ý (Sheet gid=0):', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Tên Hạ Tầng / Cơ Sở', 'Phân Loại', 'Vị Trí GPS', 'Trạng Thái Vận Hành'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final f in [
                (name: 'Lối Xuống Biển Sơn Thủy Số 1 (Lát Gỗ Đạt Chuẩn)', type: 'Lối Xuống Biển Công Cộng', gps: '16.0128, 108.2718', status: 'Hoạt động tốt, có dốc xe lăn'),
                (name: 'Bãi Đỗ Xe Công Cộng Sơn Thủy (Sức chứa 200 xe)', type: 'Bãi Đỗ Xe Du Khách', gps: '16.0120, 108.2709', status: 'Miễn phí, có bảo vệ'),
                (name: 'Trạm Cứu Hộ Bờ Biển Số 3 (Tân Trà)', type: 'Trạm Cứu Hộ Bờ Biển', gps: '16.0085, 108.2730', status: 'Trực ca 05:00 - 18:30 hằng ngày'),
                (name: 'Hyatt Regency Danang Resort & Spa (5 Sao)', type: 'Resort Ven Biển Đối Tác', gps: '16.0180, 108.2690', status: 'Liên kết ưu đãi du khách NHS360'),
                (name: 'Melia Danang Beach Resort', type: 'Resort Ven Biển Đối Tác', gps: '16.0090, 108.2725', status: 'Liên kết ưu đãi du khách NHS360'),
              ])
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(f.type, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(f.gps, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(f.status, style: const TextStyle(fontSize: 12, color: Color(0xFF15803D)))),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _flagColorValue(String flag) {
    switch (flag) {
      case 'GREEN':
        return const Color(0xFF16A34A);
      case 'YELLOW':
        return const Color(0xFFD97706);
      case 'RED':
        return const Color(0xFFDC2626);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _flagBorderColor(String flag) {
    switch (flag) {
      case 'GREEN':
        return const Color(0xFFBBF7D0);
      case 'YELLOW':
        return const Color(0xFFFDE68A);
      case 'RED':
        return const Color(0xFFFECACA);
      default:
        return AppColors.border;
    }
  }

  String _flagLabel(String flag) {
    switch (flag) {
      case 'GREEN':
        return 'CỜ XANH: AN TOÀN TẮM BIỂN';
      case 'YELLOW':
        return 'CỜ VÀNG: BIỂN ĐỘNG / CHÚ Ý';
      case 'RED':
        return 'CỜ ĐỎ: CẤM TẮM BIỂN!';
      default:
        return 'CỜ KHÔNG XÁC ĐỊNH';
    }
  }

  void _openUpdateSafetyDialog(BuildContext context, BeachSafetyNotice notice) {
    String flag = notice.flagColor;
    final waveCtrl = TextEditingController(text: notice.waveHeight);
    final msgCtrl = TextEditingController(text: notice.noticeMessage);
    bool rip = notice.ripCurrentWarning;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Cập Nhật Trạng Thái An Toàn: ${notice.beachName}'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: flag,
                  decoration: const InputDecoration(labelText: 'Mức Cờ An Toàn Bờ Biển*', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'GREEN', child: Text('🟢 CỜ XANH: An Toàn Tắm Biển')),
                    DropdownMenuItem(value: 'YELLOW', child: Text('🟡 CỜ VÀNG: Biển Động Nhẹ / Chú Ý')),
                    DropdownMenuItem(value: 'RED', child: Text('🔴 CỜ ĐỎ: CẤM TẮM BIỂN (Sóng Nguy Hiểm)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => flag = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: waveCtrl, decoration: const InputDecoration(labelText: 'Độ Cao Sóng (m)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Cảnh Báo Xuất Hiện Dòng Nước Rút (Rip Current)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  value: rip,
                  onChanged: (v) => setDialogState(() => rip = v ?? false),
                ),
                const SizedBox(height: 12),
                TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Nội Dung Cảnh Báo Gửi Du Khách', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  notice.flagColor = flag;
                  notice.waveHeight = waveCtrl.text;
                  notice.ripCurrentWarning = rip;
                  notice.noticeMessage = msgCtrl.text;
                  notice.updatedAt = 'Vừa cập nhật';
                });
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Cập Nhật Ngay'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEmergencyBroadcastDialog(BuildContext context) {
    final alertCtrl = TextEditingController(text: 'Khuyến cáo khẩn cấp: Gió giật mạnh và sóng lớn do ảnh hưởng thời tiết xấu. Đề nghị toàn bộ du khách không tắm biển và tuân thủ hướng dẫn của nhân viên cứu hộ bờ biển.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Phát Cảnh Báo Khẩn Cấp Bờ Biển (Push Notification)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hệ thống sẽ gửi thông báo đẩy (FCM) tức thì tới tất cả thiết bị du khách đang có mặt trong bán kính 3km quanh khu vực biển Ngũ Hành Sơn.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(controller: alertCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội Dung Cảnh Báo Khẩn Cấp', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã phát thông báo khẩn cấp an toàn biển thành công!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Gửi Cảnh Báo Ngay'),
          ),
        ],
      ),
    );
  }
}
