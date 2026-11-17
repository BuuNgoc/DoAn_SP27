import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// [FE-07] Dịch vụ/sự kiện/workshop có thể đặt chỗ.
class BookableService extends Equatable {
  const BookableService({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.price,
    required this.coverImage,
    required this.venue,
    required this.sessions,
    required this.remainingSlots,
    this.durationLabel = '',
    this.maxPerBooking = 10,
  });

  final String id;
  final String title;
  final String typeLabel;
  final int price;
  final String coverImage;
  final String venue;

  /// Các khung giờ có thể chọn (sự kiện cố định chỉ có 1 khung giờ).
  final List<DateTime> sessions;
  final int remainingSlots;
  final String durationLabel;
  final int maxPerBooking;

  bool get hasFixedSession => sessions.length == 1;

  @override
  List<Object?> get props => [id, remainingSlots];
}

enum BookingStatus {
  pending('booking.status_pending', Color(0xFFF2A65A), Icons.hourglass_top_rounded),
  confirmed('booking.status_confirmed', Color(0xFF4CAF7A), Icons.check_circle_rounded),
  completed('booking.status_completed', Color(0xFF58B4BC), Icons.verified_rounded),
  cancelled('booking.status_cancelled', Color(0xFFE56B6B), Icons.cancel_rounded);

  const BookingStatus(this.labelKey, this.color, this.icon);
  final String labelKey;
  final Color color;
  final IconData icon;

  String get label => AppLocalizations.trStatic(labelKey);

  static BookingStatus fromName(String? name) =>
      values.firstWhere((s) => s.name == name, orElse: () => BookingStatus.pending);
}

/// [FE-07] Đơn đặt chỗ.
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.code,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceImage,
    required this.venue,
    required this.sessionAt,
    required this.participants,
    required this.unitPrice,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
    this.note = '',
  });

  final String id;

  /// Mã đặt chỗ hiển thị & mã hóa trong QR (ví dụ: ST-8F3K2A).
  final String code;
  final String userId;
  final String serviceId;
  final String serviceTitle;
  final String serviceImage;
  final String venue;
  final DateTime sessionAt;
  final int participants;
  final int unitPrice;
  final BookingStatus status;
  final String contactName;
  final String contactPhone;
  final DateTime createdAt;
  final String note;

  int get totalPrice => unitPrice * participants;
  bool get isUpcoming => sessionAt.isAfter(DateTime.now());

  /// Chỉ hủy được đơn chưa diễn ra và cách giờ bắt đầu ít nhất 2 tiếng.
  bool get canCancel =>
      (status == BookingStatus.pending || status == BookingStatus.confirmed) &&
      sessionAt.difference(DateTime.now()) > const Duration(hours: 2);

  String get qrPayload => 'SMARTTRAVEL|BOOKING|$code|$serviceId|${sessionAt.toIso8601String()}|$participants';

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        code: code,
        userId: userId,
        serviceId: serviceId,
        serviceTitle: serviceTitle,
        serviceImage: serviceImage,
        venue: venue,
        sessionAt: sessionAt,
        participants: participants,
        unitPrice: unitPrice,
        status: status ?? this.status,
        contactName: contactName,
        contactPhone: contactPhone,
        createdAt: createdAt,
        note: note,
      );

  @override
  List<Object?> get props => [id, status];
}

class BookingRequest extends Equatable {
  const BookingRequest({
    required this.userId,
    required this.service,
    required this.sessionAt,
    required this.participants,
    required this.contactName,
    required this.contactPhone,
    this.note = '',
  });

  final String userId;
  final BookableService service;
  final DateTime sessionAt;
  final int participants;
  final String contactName;
  final String contactPhone;
  final String note;

  @override
  List<Object?> get props => [userId, service, sessionAt, participants];
}
