import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/models/localized_text_model.dart';
import '../../domain/entities/destination.dart';

/// [FE-02] Model ánh xạ tài liệu Firestore `destinations/{id}`.
/// Các trường văn bản lưu dạng map đa ngữ `{vi, en, ko, zh}` (LI-06).
class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.category,
    required super.shortDescription,
    required super.overview,
    required super.culturalHistory,
    required super.address,
    required super.openingHours,
    required super.ticketInfo,
    required super.latitude,
    required super.longitude,
    required super.coverImage,
    super.gallery,
    super.videoCount,
    super.hasVr360,
    super.hasAudioGuide,
    super.ratingAvg,
    super.reviewCount,
    super.tags,
    super.visitDurationMinutes,
    super.highlights,
    super.beachSafetyInfo,
  });

  factory DestinationModel.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    String? lang,
  }) {
    final resolvedLang =
        lang ?? AppLocalizations.current?.locale.languageCode ?? AppConfig.defaultLanguage;
    String text(String key) => LocalizedTextModel.fromLocalizedMap(
          data[key] as Map<String, dynamic>?,
          languageCode: resolvedLang,
        );

    final location = data['location'] as Map<String, dynamic>? ?? const {};

    // Xử lý tọa độ Geopoint (hỗ trợ cả Firestore GeoPoint và Map {latitude, longitude})
    final rawGeo = location['geopoint'];
    double lat = 16.0036;
    double lng = 108.2634;
    if (rawGeo is GeoPoint) {
      lat = rawGeo.latitude;
      lng = rawGeo.longitude;
    } else if (rawGeo is Map) {
      lat = (rawGeo['latitude'] as num?)?.toDouble() ?? 16.0036;
      lng = (rawGeo['longitude'] as num?)?.toDouble() ?? 108.2634;
    }

    // Xử lý địa chỉ (hỗ trợ cả Map đa ngôn ngữ và String đơn)
    String parseAddress() {
      final raw = location['address'];
      if (raw is Map) {
        final localized = LocalizedTextModel.fromLocalizedMap(
          Map<String, dynamic>.from(raw),
          languageCode: resolvedLang,
        );
        if (localized.isNotEmpty) return localized;
      }
      if (raw is String) return raw;
      return 'Ngũ Hành Sơn, Đà Nẵng';
    }

    // Xử lý giờ mở cửa (hỗ trợ cả Map {open, close} và String)
    String parseOpeningHours() {
      final raw = data['openingHours'];
      if (raw is Map) {
        final open = raw['open'] ?? '07:00';
        final close = raw['close'] ?? '17:30';
        return '$open - $close';
      }
      if (raw is String) return raw;
      return '07:00 - 17:30';
    }

    // Xử lý giá vé (hỗ trợ cả ticketPrice map {adult, note} và ticketInfo)
    String parseTicketInfo() {
      final rawInfo = data['ticketInfo'];
      if (rawInfo is String && rawInfo.isNotEmpty) return rawInfo;
      final rawPrice = data['ticketPrice'];
      if (rawPrice is Map) {
        final note = rawPrice['note'];
        if (note is Map) {
          final noteStr = LocalizedTextModel.fromLocalizedMap(
            Map<String, dynamic>.from(note),
            languageCode: resolvedLang,
          );
          if (noteStr.isNotEmpty) return noteStr;
        }
        final adult = rawPrice['adult'];
        if (adult is num && adult > 0) return '${adult.toInt()} VNĐ / vé';
        return 'Miễn phí vé vào';
      }
      return '40.000 VNĐ / vé';
    }

    // Xử lý mô tả ngắn gọn
    String shortDesc = text('shortDescription');
    if (shortDesc.isEmpty) {
      final ov = text('overview');
      shortDesc = ov.length > 120 ? '${ov.substring(0, 120)}...' : ov;
    }

    final images = List<String>.from(data['images'] as List? ?? const []);
    final culturalHist = text('culturalHistoricalInfo').isNotEmpty
        ? text('culturalHistoricalInfo')
        : text('culturalHistory');

    return DestinationModel(
      id: id,
      name: text('name'),
      category: DestinationCategory.fromCode(data['category'] as String?) ?? DestinationCategory.mountainCave,
      shortDescription: shortDesc,
      overview: text('overview'),
      culturalHistory: culturalHist,
      address: parseAddress(),
      openingHours: parseOpeningHours(),
      ticketInfo: parseTicketInfo(),
      latitude: lat,
      longitude: lng,
      coverImage: images.isEmpty ? '' : images.first,
      gallery: images,
      videoCount: (data['videoCount'] as num?)?.toInt() ?? 0,
      hasVr360: data['hasVr360'] as bool? ?? false,
      hasAudioGuide: data['hasAudioGuide'] as bool? ?? false,
      ratingAvg: (data['ratingAvg'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      visitDurationMinutes: (data['visitDurationMinutes'] as num?)?.toInt() ?? 60,
      highlights: List<String>.from(data['highlights'] as List? ?? const []),
      beachSafetyInfo: data['beachSafetyInfo'] == null ? null : text('beachSafetyInfo'),
    );
  }
}
