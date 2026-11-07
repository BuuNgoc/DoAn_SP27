import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// [FE-04] Các lớp bản đồ có thể bật/tắt.
enum MapLayer {
  attraction('attraction', 'Điểm tham quan', Icons.landscape_rounded, Color(0xFF24838B)),
  dining('dining', 'Nhà hàng & Dịch vụ', Icons.restaurant_rounded, Color(0xFFF2A65A)),
  beach('beach', 'Bãi biển', Icons.beach_access_rounded, Color(0xFF3E9FD6)),
  anThuong('an_thuong', 'Khu An Thượng', Icons.nightlife_rounded, Color(0xFF9B7BD4)),
  workshopEvent('workshop_event', 'Workshop & Sự kiện', Icons.event_rounded, Color(0xFFE56B6B)),
  qrCheckin('qr_checkin', 'Điểm QR Check-in', Icons.qr_code_2_rounded, Color(0xFFE4B363));

  const MapLayer(this.code, this.label, this.icon, this.color);
  final String code;
  final String label;
  final IconData icon;
  final Color color;

  static MapLayer fromCode(String code) =>
      values.firstWhere((e) => e.code == code, orElse: () => MapLayer.attraction);
}

/// [FE-04] Một điểm quan tâm (POI) trên bản đồ.
class MapPoi extends Equatable {
  const MapPoi({
    required this.id,
    required this.name,
    required this.layer,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    this.openingHours,
    this.rating,
    this.priceHint,
    this.image,
    this.destinationId,
    this.eventId,
  });

  final String id;
  final String name;
  final MapLayer layer;
  final double latitude;
  final double longitude;
  final String address;
  final String description;
  final String? openingHours;
  final double? rating;
  final String? priceHint;
  final String? image;

  /// Liên kết tới trang chi tiết điểm đến (FE-02) nếu có.
  final String? destinationId;

  /// Liên kết tới trang chi tiết sự kiện/workshop (FE-06) nếu có.
  final String? eventId;

  @override
  List<Object?> get props => [id];
}
