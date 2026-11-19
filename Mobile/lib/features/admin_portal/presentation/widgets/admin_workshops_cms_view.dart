import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class WorkshopTicketBooking {
  WorkshopTicketBooking({
    required this.ticketCode,
    required this.touristName,
    required this.phone,
    required this.workshopTitle,
    required this.sessionTime,
    required this.participants,
    required this.status, // 'CONFIRMED', 'CHECKED_IN'
    required this.certificateCode,
  });

  final String ticketCode;
  final String touristName;
  final String phone;
  final String workshopTitle;
  final String sessionTime;
  final int participants;
  String status;
  String certificateCode;
}

/// [FE-15, FE-19 / Epic 7] Quản Trị Workshop Làng Nghề & Công Cụ Quét QR Xác Nhận Tham Gia (Website CMS)
class AdminWorkshopsCmsView extends StatefulWidget {
  const AdminWorkshopsCmsView({super.key});

  @override
  State<AdminWorkshopsCmsView> createState() => _AdminWorkshopsCmsViewState();
}

class _AdminWorkshopsCmsViewState extends State<AdminWorkshopsCmsView> {
  final TextEditingController _qrInputCtrl = TextEditingController();
  String? _validationResult;
  bool _isSuccessValidation = false;

  late final List<WorkshopTicketBooking> _bookings = [
    WorkshopTicketBooking(
      ticketCode: 'TK-NHS-WS8821',
      touristName: 'Trần Văn Hoàng',
      phone: '0905 111 222',
      workshopTitle: 'Workshop Chạm Khắc Tượng Chibi Bằng Đá Mềm',
      sessionTime: 'Thứ 7, 21/11/2026 (08:30 - 10:30)',
      participants: 2,
      status: 'CONFIRMED',
      certificateCode: '',
    ),
    WorkshopTicketBooking(
      ticketCode: 'TK-NHS-WS8822',
      touristName: 'Michael Brown (Du khách Úc)',
      phone: '+61 412 345 678',
      workshopTitle: 'Trải Nghiệm Đục Đẽo Đá Truyền Thống 400 Năm',
      sessionTime: 'Thứ 7, 21/11/2026 (14:30 - 16:30)',
      participants: 1,
      status: 'CONFIRMED',
      certificateCode: '',
    ),
    WorkshopTicketBooking(
      ticketCode: 'TK-NHS-WS8819',
      touristName: 'Lê Thị Mai Anh',
      phone: '0918 888 999',
      workshopTitle: 'Làm Vòng Tay Phong Thủy Từ Đá Cẩm Thạch',
      sessionTime: 'Hôm nay (09:00 - 11:00)',
      participants: 1,
      status: 'CHECKED_IN',
      certificateCode: 'CERT-NHS-2026-0042',
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
                    'Quản Trị Workshop Làng Nghề & Xác Thực Vé QR (FE-19, Epic 7)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quản lý ca trải nghiệm cùng nghệ nhân, công cụ quét QR xác nhận tham gia, tự động tích điểm Loyalty & cấp E-Certificate',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openCreateWorkshopDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('+ Tạo Workshop Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── QR Ticket Validation Simulator Tool (Staff / Admin Tool) ────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Công Cụ Quét & Kiểm Tra Mã QR Vé Tham Gia (Staff / Admin QR Ticket Validator)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Nhân viên/Nghệ nhân dùng đầu đọc mã vạch hoặc camera để quét mã QR vé của du khách khi đến xưởng:',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 320,
                      height: 42,
                      child: TextField(
                        controller: _qrInputCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nhập hoặc quét mã vé (VD: TK-NHS-WS8821)',
                          hintStyle: const TextStyle(fontSize: 12.5),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _validateAndCheckinTicket,
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: const Text('Xác Thực Vé & Check-in'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        _qrInputCtrl.text = 'TK-NHS-WS8821';
                        _validateAndCheckinTicket();
                      },
                      child: const Text('Thử nghiệm vé mẫu (TK-NHS-WS8821)'),
                    ),
                  ],
                ),
                if (_validationResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccessValidation ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isSuccessValidation ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccessValidation ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: _isSuccessValidation ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _validationResult!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _isSuccessValidation ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Workshop Sessions & Bookings Table ──────────────────────────────
          const Text('Danh Sách Du Khách Đăng Ký Tham Gia Workshop:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(3.2),
              3: FlexColumnWidth(2.2),
              4: FlexColumnWidth(1.6),
              5: FlexColumnWidth(2.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Mã Vé QR', 'Họ Tên Du Khách', 'Tên Workshop & Ca Diễn', 'Thời Gian', 'Trạng Thái', 'Chứng Nhận E-Cert'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final b in _bookings)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(b.ticketCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'monospace')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.touristName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('SĐT: ${b.phone} • ${b.participants} người', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(b.workshopTitle, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(b.sessionTime, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: b.status == 'CHECKED_IN' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          b.status == 'CHECKED_IN' ? 'Đã Tham Gia' : 'Chờ Check-in',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: b.status == 'CHECKED_IN' ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        b.certificateCode.isNotEmpty ? b.certificateCode : '(Chưa cấp)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: b.certificateCode.isNotEmpty ? AppColors.primary : AppColors.textMuted,
                          fontFamily: 'monospace',
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

  void _validateAndCheckinTicket() {
    final code = _qrInputCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _validationResult = 'Vui lòng nhập hoặc quét mã vé QR!';
        _isSuccessValidation = false;
      });
      return;
    }

    final match = _bookings.where((b) => b.ticketCode.toUpperCase() == code.toUpperCase()).toList();
    if (match.isEmpty) {
      setState(() {
        _validationResult = 'Mã vé "$code" không tồn tại trên hệ thống hoặc không hợp lệ!';
        _isSuccessValidation = false;
      });
    } else {
      final ticket = match.first;
      if (ticket.status == 'CHECKED_IN') {
        setState(() {
          _validationResult = 'Vé "${ticket.ticketCode}" (${ticket.touristName}) ĐÃ CHECK-IN TRƯỚC ĐÓ lúc hoàn tất session!';
          _isSuccessValidation = false;
        });
      } else {
        setState(() {
          ticket.status = 'CHECKED_IN';
          ticket.certificateCode = 'CERT-NHS-2026-${(1000 + _bookings.indexOf(ticket)).toString()}';
          _validationResult = 'Xác thực THÀNH CÔNG! Đã check-in cho "${ticket.touristName}". Tự động cộng +50 Điểm Loyalty & Cấp E-Certificate: ${ticket.certificateCode}!';
          _isSuccessValidation = true;
        });
      }
    }
  }

  void _openCreateWorkshopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo Workshop Làng Nghề Mới (FE-19)'),
        content: const SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Tên Workshop*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Nghệ Nhân Hướng Dẫn*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Địa Điểm Xưởng Đá*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Giá Vé (VNĐ/người)*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Sức Chứa Tối Đa (Số khách)*', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Lưu Workshop'),
          ),
        ],
      ),
    );
  }
}
