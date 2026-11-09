import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// Phân khu trải nghiệm chuyên biệt.
enum ZoneType { anThuong, beach }

/// Loại địa điểm trong phân khu.
enum ZoneSpotCategory {
  food('zones.spot_food', Icons.ramen_dining_rounded),
  cafe('zones.spot_cafe', Icons.local_cafe_rounded),
  nightlife('zones.spot_nightlife', Icons.nightlife_rounded),
  beachActivity('zones.spot_beach_activity', Icons.surfing_rounded),
  beachService('zones.spot_beach_service', Icons.room_service_rounded);

  const ZoneSpotCategory(this.labelKey, this.icon);
  final String labelKey;
  final IconData icon;
  String get label => AppLocalizations.trStatic(labelKey);
}

/// [FE-12, FE-13] Nhà hàng, quán bar, hoạt động biển, dịch vụ tiện ích...
class ZoneSpot extends Equatable {
  const ZoneSpot({
    required this.id,
    required this.zone,
    required this.name,
    required this.category,
    required this.description,
    required this.image,
    required this.address,
    required this.openingHours,
    required this.priceRange,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.tags = const [],
    this.bookableServiceId,
  });

  final String id;
  final ZoneType zone;
  final String name;
  final ZoneSpotCategory category;
  final String description;
  final String image;
  final String address;
  final String openingHours;
  final String priceRange;
  final double latitude;
  final double longitude;
  final double? rating;
  final List<String> tags;

  /// Nếu có: cho phép đặt chỗ qua FE-07.
  final String? bookableServiceId;

  @override
  List<Object?> get props => [id];
}

/// Mức an toàn tắm biển (theo cờ hiệu cứu hộ).
enum SafetyLevel {
  safe('zones.safety_safe_label', 'zones.safety_safe_advice', Color(0xFF4CAF7A), Icons.verified_user_rounded),
  caution('zones.safety_caution_label', 'zones.safety_caution_advice', Color(0xFFF2A65A), Icons.warning_amber_rounded),
  danger('zones.safety_danger_label', 'zones.safety_danger_advice', Color(0xFFE56B6B), Icons.dangerous_rounded);

  const SafetyLevel(this.labelKey, this.adviceKey, this.color, this.icon);
  final String labelKey;
  final String adviceKey;
  final Color color;
  final IconData icon;
  String get label => AppLocalizations.trStatic(labelKey);
  String get advice => AppLocalizations.trStatic(adviceKey);
}

/// [FE-13] Bãi tắm.
class BeachArea extends Equatable {
  const BeachArea({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.lifeguardHours,
    required this.facilities,
    required this.safetyLevel,
    this.destinationId,
  });

  final String id;
  final String name;
  final String description;
  final String image;
  final String lifeguardHours;
  final List<String> facilities;
  final SafetyLevel safetyLevel;
  final String? destinationId;

  @override
  List<Object?> get props => [id, safetyLevel];
}

class EmergencyContact {
  const EmergencyContact(this.label, this.phone, this.icon);
  final String label;
  final String phone;
  final IconData icon;
}

/// [FE-13] Thông tin an toàn bãi biển (cập nhật bởi Ban quản lý bãi biển).
class BeachSafetyInfo extends Equatable {
  const BeachSafetyInfo({
    required this.overallLevel,
    required this.waveHeight,
    required this.windSpeed,
    required this.waterTemperature,
    required this.uvIndex,
    required this.updatedAt,
    required this.headline,
    required this.tips,
    required this.contacts,
  });

  final SafetyLevel overallLevel;
  final String waveHeight;
  final String windSpeed;
  final String waterTemperature;
  final String uvIndex;
  final DateTime updatedAt;
  final String headline;
  final List<String> tips;
  final List<EmergencyContact> contacts;

  @override
  List<Object?> get props => [overallLevel, updatedAt];
}

/// Dữ liệu tổng hợp của một phân khu.
class ZoneOverview extends Equatable {
  const ZoneOverview({
    required this.zone,
    required this.title,
    required this.tagline,
    required this.introduction,
    required this.heroImage,
    required this.spots,
    required this.relatedEventIds,
    this.tips = const [],
    this.beaches = const [],
    this.safety,
  });

  final ZoneType zone;
  final String title;
  final String tagline;
  final String introduction;
  final String heroImage;
  final List<ZoneSpot> spots;
  final List<String> relatedEventIds;
  final List<String> tips;
  final List<BeachArea> beaches;
  final BeachSafetyInfo? safety;

  @override
  List<Object?> get props => [zone, spots, beaches, safety];
}

/// [FE-14] Nội dung chào mừng du khách quét QR tại Sân bay Quốc tế Đà Nẵng.
class AirportWelcomeContent extends Equatable {
  const AirportWelcomeContent({
    required this.campaignId,
    required this.headline,
    required this.message,
    required this.heroImage,
    required this.distanceFromAirport,
    required this.travelOptions,
    required this.quickFacts,
    required this.featuredDestinationIds,
    required this.featuredEventIds,
    required this.welcomeOffer,
  });

  final String campaignId;
  final String headline;
  final String message;
  final String heroImage;
  final String distanceFromAirport;
  final List<({IconData icon, String title, String detail})> travelOptions;
  final List<({IconData icon, String value, String label})> quickFacts;
  final List<String> featuredDestinationIds;
  final List<String> featuredEventIds;
  final String welcomeOffer;

  @override
  List<Object?> get props => [campaignId];
}
