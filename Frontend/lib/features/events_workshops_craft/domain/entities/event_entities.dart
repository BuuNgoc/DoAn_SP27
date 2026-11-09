import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum EventKind {
  event('event', 'events.kind_event', Icons.celebration_rounded),
  workshop('workshop', 'events.kind_workshop', Icons.handyman_rounded);

  const EventKind(this.code, this.labelKey, this.icon);
  final String code;
  final String labelKey;
  final IconData icon;

  String get label => AppLocalizations.trStatic(labelKey);

  static EventKind fromCode(String code) => values.firstWhere((e) => e.code == code, orElse: () => EventKind.event);
}

/// [FE-06] Sự kiện / workshop tại Ngũ Hành Sơn.
class EventWorkshop extends Equatable {
  const EventWorkshop({
    required this.id,
    required this.title,
    required this.kind,
    required this.category,
    required this.summary,
    required this.description,
    required this.startAt,
    required this.endAt,
    required this.venue,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.price,
    required this.capacity,
    required this.bookedCount,
    required this.coverImage,
    required this.organizer,
    this.schedule = const [],
    this.includes = const [],
    this.artisanId,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final EventKind kind;
  final String category;
  final String summary;
  final String description;
  final DateTime startAt;
  final DateTime endAt;
  final String venue;
  final String address;
  final double latitude;
  final double longitude;
  final int price;
  final int capacity;
  final int bookedCount;
  final String coverImage;
  final String organizer;

  /// Lịch trình chi tiết dạng "08:00 – Đón khách".
  final List<String> schedule;
  final List<String> includes;
  final String? artisanId;
  final bool isFeatured;

  int get remainingSlots => (capacity - bookedCount).clamp(0, capacity);
  bool get isFull => remainingSlots == 0;
  double get fillRate => capacity == 0 ? 0 : bookedCount / capacity;
  bool get isUpcoming => endAt.isAfter(DateTime.now());

  @override
  List<Object?> get props => [id, bookedCount];
}

/// [FE-15] Nghệ nhân Làng đá mỹ nghệ Non Nước.
class Artisan extends Equatable {
  const Artisan({
    required this.id,
    required this.name,
    required this.title,
    required this.yearsOfExperience,
    required this.specialty,
    required this.bio,
    required this.craftHistory,
    required this.avatar,
    required this.workshopAddress,
    this.featuredWorks = const [],
    this.awards = const [],
    this.workshopIds = const [],
    this.rating = 5,
  });

  final String id;
  final String name;
  final String title;
  final int yearsOfExperience;
  final String specialty;
  final String bio;
  final String craftHistory;
  final String avatar;
  final String workshopAddress;
  final List<ArtisanWork> featuredWorks;
  final List<String> awards;
  final List<String> workshopIds;
  final double rating;

  @override
  List<Object?> get props => [id];
}

class ArtisanWork extends Equatable {
  const ArtisanWork({required this.title, required this.image, required this.material});
  final String title;
  final String image;
  final String material;

  @override
  List<Object?> get props => [title];
}

enum ContestStatus {
  upcoming('contest.status_upcoming'),
  voting('contest.status_voting'),
  ended('contest.status_ended');

  const ContestStatus(this.labelKey);
  final String labelKey;

  String get label => AppLocalizations.trStatic(labelKey);
}

/// [FE-16] Cuộc thi điêu khắc đá.
class StoneCarvingContest extends Equatable {
  const StoneCarvingContest({
    required this.id,
    required this.title,
    required this.theme,
    required this.description,
    required this.startAt,
    required this.votingEndsAt,
    required this.status,
    required this.coverImage,
    this.prizes = const [],
    this.rules = const [],
    this.organizer = 'Hiệp hội Làng nghề đá mỹ nghệ Non Nước',
  });

  final String id;
  final String title;
  final String theme;
  final String description;
  final DateTime startAt;
  final DateTime votingEndsAt;
  final ContestStatus status;
  final String coverImage;
  final List<String> prizes;
  final List<String> rules;
  final String organizer;

  bool get canVote => status == ContestStatus.voting;

  @override
  List<Object?> get props => [id, status];
}

class ContestEntry extends Equatable {
  const ContestEntry({
    required this.id,
    required this.contestId,
    required this.title,
    required this.artistName,
    required this.artistOrigin,
    required this.material,
    required this.dimensions,
    required this.description,
    required this.image,
    required this.voteCount,
    this.hasVoted = false,
  });

  final String id;
  final String contestId;
  final String title;
  final String artistName;
  final String artistOrigin;
  final String material;
  final String dimensions;
  final String description;
  final String image;
  final int voteCount;

  /// Người dùng hiện tại đã bình chọn tác phẩm này chưa.
  final bool hasVoted;

  ContestEntry copyWith({int? voteCount, bool? hasVoted}) => ContestEntry(
        id: id,
        contestId: contestId,
        title: title,
        artistName: artistName,
        artistOrigin: artistOrigin,
        material: material,
        dimensions: dimensions,
        description: description,
        image: image,
        voteCount: voteCount ?? this.voteCount,
        hasVoted: hasVoted ?? this.hasVoted,
      );

  @override
  List<Object?> get props => [id, voteCount, hasVoted];
}
