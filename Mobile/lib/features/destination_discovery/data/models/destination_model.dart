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
    final geo = location['geopoint'] as GeoPoint? ?? const GeoPoint(16.0036, 108.2636);
    final images = List<String>.from(data['images'] as List? ?? const []);

    return DestinationModel(
      id: id,
      name: text('name'),
      category: DestinationCategory.fromCode(data['category'] as String?) ?? DestinationCategory.mountainCave,
      shortDescription: text('shortDescription'),
      overview: text('overview'),
      culturalHistory: text('culturalHistoricalInfo'),
      address: location['address'] as String? ?? '',
      openingHours: data['openingHours'] as String? ?? '',
      ticketInfo: data['ticketInfo'] as String? ?? '',
      latitude: geo.latitude,
      longitude: geo.longitude,
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
