import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

/// Danh mục điểm đến tại Ngũ Hành Sơn (bộ lọc ngang trên Trang chủ).
enum DestinationCategory {
  mountainCave('mountain_cave', 'destinations.category_mountain_cave', Icons.terrain_rounded),
  pagoda('pagoda', 'destinations.category_pagoda', Icons.temple_buddhist_rounded),
  craftVillage('craft_village', 'destinations.category_craft_village', Icons.handyman_rounded),
  beach('beach', 'destinations.category_beach', Icons.beach_access_rounded),
  anThuong('an_thuong', 'destinations.category_an_thuong', Icons.nightlife_rounded);

  const DestinationCategory(this.code, this.labelKey, this.icon);
  final String code;
  final String labelKey;
  final IconData icon;

  /// Nhãn đa ngôn ngữ theo ngôn ngữ hiện hành.
  String get label => AppLocalizations.trStatic(labelKey);

  /// Nhãn đa ngôn ngữ đọc trực tiếp từ `BuildContext`.
  String localizedLabel(BuildContext context) => context.tr(labelKey);

  static DestinationCategory? fromCode(String? code) {
    for (final c in DestinationCategory.values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// [FE-02] Điểm đến du lịch.
class Destination extends Equatable {
  const Destination({
    required this.id,
    required this.name,
    required this.category,
    required this.shortDescription,
    required this.overview,
    required this.culturalHistory,
    required this.address,
    required this.openingHours,
    required this.ticketInfo,
    required this.latitude,
    required this.longitude,
    required this.coverImage,
    this.gallery = const [],
    this.videoCount = 0,
    this.hasVr360 = false,
    this.hasAudioGuide = false,
    this.ratingAvg = 0,
    this.reviewCount = 0,
    this.tags = const [],
    this.visitDurationMinutes = 60,
    this.highlights = const [],
    this.beachSafetyInfo,
  });

  final String id;
  final String name;
  final DestinationCategory category;
  final String shortDescription;
  final String overview;
  final String culturalHistory;
  final String address;
  final String openingHours;
  final String ticketInfo;
  final double latitude;
  final double longitude;
  final String coverImage;
  final List<String> gallery;
  final int videoCount;

  /// Chỉ hiển thị nút VR360 khi `hasVr360 == true`.
  final bool hasVr360;
  final bool hasAudioGuide;
  final double ratingAvg;
  final int reviewCount;
  final List<String> tags;
  final int visitDurationMinutes;
  final List<String> highlights;
  final String? beachSafetyInfo;

  @override
  List<Object?> get props => [id, name, shortDescription, ratingAvg, reviewCount];
}
