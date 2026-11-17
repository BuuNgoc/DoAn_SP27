import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_entities.dart';

DateTime _date(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}

String _text(dynamic v) => v is Map ? (v['vi'] ?? '').toString() : (v ?? '').toString();

/// Ánh xạ tài liệu Firestore → entity cho phân hệ sự kiện/nghệ nhân/cuộc thi.
class EventModels {
  EventModels._();

  static EventWorkshop event(Map<String, dynamic> j, String id) {
    final loc = j['location'];
    final geo = loc is GeoPoint ? loc : (loc is Map ? loc['geopoint'] as GeoPoint? : null);
    return EventWorkshop(
      id: id,
      title: _text(j['title']),
      kind: EventKind.fromCode((j['type'] ?? 'event').toString()),
      category: (j['category'] ?? '').toString(),
      summary: _text(j['summary']),
      description: _text(j['description']),
      startAt: _date(j['startAt']),
      endAt: _date(j['endAt']),
      venue: (j['venue'] ?? '').toString(),
      address: (j['address'] ?? '').toString(),
      latitude: geo?.latitude ?? 0,
      longitude: geo?.longitude ?? 0,
      price: (j['price'] as num? ?? 0).toInt(),
      capacity: (j['capacity'] as num? ?? 0).toInt(),
      bookedCount: (j['bookedCount'] as num? ?? 0).toInt(),
      coverImage: (j['coverImageUrl'] ?? '').toString(),
      organizer: (j['organizer'] ?? '').toString(),
      schedule: List<String>.from(j['schedule'] ?? const []),
      includes: List<String>.from(j['includes'] ?? const []),
      artisanId: j['artisanId']?.toString(),
      isFeatured: j['isFeatured'] == true,
    );
  }

  static Artisan artisan(Map<String, dynamic> j, String id) => Artisan(
        id: id,
        name: (j['name'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        yearsOfExperience: (j['yearsOfExperience'] as num? ?? 0).toInt(),
        specialty: (j['specialty'] ?? '').toString(),
        bio: _text(j['bio']),
        craftHistory: _text(j['craftHistory']),
        avatar: (j['avatarUrl'] ?? '').toString(),
        workshopAddress: (j['workshopAddress'] ?? '').toString(),
        featuredWorks: [
          for (final w in (j['featuredWorks'] as List? ?? const []))
            ArtisanWork(
              title: (w['title'] ?? '').toString(),
              image: (w['imageUrl'] ?? '').toString(),
              material: (w['material'] ?? '').toString(),
            ),
        ],
        awards: List<String>.from(j['awards'] ?? const []),
        workshopIds: List<String>.from(j['workshopIds'] ?? const []),
        rating: (j['rating'] as num? ?? 5).toDouble(),
      );

  static StoneCarvingContest contest(Map<String, dynamic> j, String id) => StoneCarvingContest(
        id: id,
        title: _text(j['title']),
        theme: _text(j['theme']),
        description: _text(j['description']),
        startAt: _date(j['startAt']),
        votingEndsAt: _date(j['votingEndsAt']),
        status: ContestStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => ContestStatus.voting),
        coverImage: (j['coverImageUrl'] ?? '').toString(),
        prizes: List<String>.from(j['prizes'] ?? const []),
        rules: List<String>.from(j['rules'] ?? const []),
      );

  static ContestEntry entry(Map<String, dynamic> j, String id, String contestId, {bool hasVoted = false}) =>
      ContestEntry(
        id: id,
        contestId: contestId,
        title: _text(j['title']),
        artistName: (j['artistName'] ?? '').toString(),
        artistOrigin: (j['artistOrigin'] ?? '').toString(),
        material: (j['material'] ?? '').toString(),
        dimensions: (j['dimensions'] ?? '').toString(),
        description: _text(j['description']),
        image: (j['imageUrl'] ?? '').toString(),
        voteCount: (j['voteCount'] as num? ?? 0).toInt(),
        hasVoted: hasVoted,
      );
}
