import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../domain/entities/booking_entities.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) => PillBadge(label: status.label, icon: status.icon, color: status.color);
}

/// Thẻ QR xác nhận đặt chỗ – xuất trình tại quầy.
class BookingQrCard extends StatelessWidget {
  const BookingQrCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final inactive = booking.status == BookingStatus.cancelled;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Mã đặt chỗ', style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
          const SizedBox(height: 4),
          SelectableText(
            booking.code,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 2, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 14),
          Opacity(
            opacity: inactive ? 0.25 : 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: QrImageView(
                data: booking.qrPayload,
                size: 190,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: AppColors.textPrimary),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            inactive ? 'Đơn đã hủy – mã QR không còn hiệu lực.' : 'Vui lòng xuất trình mã QR này tại quầy check-in.',
            textAlign: TextAlign.center,
            style: TextStyle(color: inactive ? AppColors.error : AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Bảng tóm tắt thông tin đơn.
class BookingSummaryCard extends StatelessWidget {
  const BookingSummaryCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              CoverImage(source: b.serviceImage, width: 64, height: 64, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.serviceTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    BookingStatusBadge(status: b.status),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 26),
          _row('Thời gian', '${DateFormatter.formatTime(b.sessionAt)} · ${DateFormatter.formatWithWeekday(b.sessionAt)}'),
          _row('Địa điểm', b.venue),
          _row('Số người', '${b.participants} người'),
          _row('Người liên hệ', '${b.contactName} · ${b.contactPhone}'),
          if (b.note.isNotEmpty) _row('Ghi chú', b.note),
          const Divider(height: 22),
          Row(
            children: [
              const Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                CurrencyFormatter.vnd(b.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryTeal),
              ),
            ],
          ),
          if (b.totalPrice > 0)
            const Align(
              alignment: Alignment.centerRight,
              child: Text('Thanh toán tại quầy khi check-in', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
          ],
        ),
      );
}

class BookingListTile extends StatelessWidget {
  const BookingListTile({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(RouteNames.bookingDetail(b.id)),
      child: Row(
        children: [
          CoverImage(source: b.serviceImage, width: 72, height: 72, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.serviceTitle,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  '${DateFormatter.formatTime(b.sessionAt)} · ${DateFormatter.formatDateOnly(b.sessionAt)} · ${b.participants} người',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    BookingStatusBadge(status: b.status),
                    const Spacer(),
                    Text(b.code, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
