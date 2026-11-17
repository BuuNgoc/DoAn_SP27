import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/event_entities.dart';
import '../models/event_models.dart';
import 'event_sample_data.dart';

/// [FE-06, FE-15, FE-16] Nguồn dữ liệu sự kiện, nghệ nhân, cuộc thi.
abstract class EventsRemoteDataSource {
  Future<List<EventWorkshop>> fetchEvents();
  Future<List<Artisan>> fetchArtisans();
  Future<StoneCarvingContest> fetchActiveContest();
  Future<List<ContestEntry>> fetchEntries(String contestId, String? userId);
  Future<ContestEntry> vote(String contestId, String entryId, String userId);

  /// Giữ chỗ (+) hoặc trả chỗ (−) khi đặt/hủy booking.
  Future<void> adjustBookedCount(String eventId, int delta);
}

class MockEventsRemoteDataSource implements EventsRemoteDataSource {
  late final List<EventWorkshop> _events = EventSampleData.events();
  late final Map<String, ContestEntry> _entries = {for (final e in EventSampleData.entries) e.id: e};
  final Set<String> _votes = {}; // "$userId|$entryId"

  @override
  Future<List<EventWorkshop>> fetchEvents() async {
    await simulateLatency();
    return List.unmodifiable(_events);
  }

  @override
  Future<List<Artisan>> fetchArtisans() async {
    await simulateLatency();
    return EventSampleData.artisans;
  }

  @override
  Future<StoneCarvingContest> fetchActiveContest() async {
    await simulateLatency();
    return EventSampleData.contest();
  }

  @override
  Future<List<ContestEntry>> fetchEntries(String contestId, String? userId) async {
    await simulateLatency();
    return _entries.values
        .where((e) => e.contestId == contestId)
        .map((e) => e.copyWith(hasVoted: userId != null && _votes.contains('$userId|${e.id}')))
        .toList();
  }

  @override
  Future<ContestEntry> vote(String contestId, String entryId, String userId) async {
    await simulateLatency();
    final entry = _entries[entryId];
    if (entry == null) throw const ServerException('Không tìm thấy tác phẩm.');
    final key = '$userId|$entryId';
    if (_votes.contains(key)) throw const ServerException('Bạn đã bình chọn cho tác phẩm này rồi.');
    _votes.add(key);
    final updated = entry.copyWith(voteCount: entry.voteCount + 1);
    _entries[entryId] = updated;
    return updated.copyWith(hasVoted: true);
  }

  @override
  Future<void> adjustBookedCount(String eventId, int delta) async {
    final i = _events.indexWhere((e) => e.id == eventId);
    if (i < 0) return;
    final e = _events[i];
    _events[i] = EventWorkshop(
      id: e.id,
      title: e.title,
      kind: e.kind,
      category: e.category,
      summary: e.summary,
      description: e.description,
      startAt: e.startAt,
      endAt: e.endAt,
      venue: e.venue,
      address: e.address,
      latitude: e.latitude,
      longitude: e.longitude,
      price: e.price,
      capacity: e.capacity,
      bookedCount: (e.bookedCount + delta).clamp(0, e.capacity),
      coverImage: e.coverImage,
      organizer: e.organizer,
      schedule: e.schedule,
      includes: e.includes,
      artisanId: e.artisanId,
      isFeatured: e.isFeatured,
    );
  }
}

class FirestoreEventsRemoteDataSource implements EventsRemoteDataSource {
  FirestoreEventsRemoteDataSource([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Lỗi kết nối máy chủ.', code: e.code);
    }
  }

  @override
  Future<List<EventWorkshop>> fetchEvents() => _guard(() async {
        final snap = await _db
            .collection(FirestoreCollections.eventsWorkshops)
            .where('status', isEqualTo: 'published')
            .get();
        if (snap.docs.isEmpty) {
          return EventSampleData.events();
        }
        final list = snap.docs.map((d) => EventModels.event(d.data(), d.id)).toList();
        list.sort((a, b) => a.startAt.compareTo(b.startAt));
        return list;
      });

  @override
  Future<List<Artisan>> fetchArtisans() => _guard(() async {
        final snap = await _db.collection(FirestoreCollections.artisans).get();
        if (snap.docs.isEmpty) {
          return EventSampleData.artisans;
        }
        return snap.docs.map((d) => EventModels.artisan(d.data(), d.id)).toList();
      });

  @override
  Future<StoneCarvingContest> fetchActiveContest() => _guard(() async {
        try {
          final snap = await _db
              .collection(FirestoreCollections.stoneCarvingContests)
              .orderBy('startAt', descending: true)
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            return EventModels.contest(snap.docs.first.data(), snap.docs.first.id);
          }
        } catch (_) {}
        return EventSampleData.contest();
      });

  @override
  Future<List<ContestEntry>> fetchEntries(String contestId, String? userId) => _guard(() async {
        final contestRef = _db.collection(FirestoreCollections.stoneCarvingContests).doc(contestId);
        final snap = await contestRef.collection(FirestoreCollections.subContestEntries).get();
        if (snap.docs.isEmpty) {
          return EventSampleData.entries.where((e) => e.contestId == contestId).toList();
        }
        final voted = <String>{};
        if (userId != null) {
          final votes = await contestRef
              .collection(FirestoreCollections.subContestVotes)
              .where('userId', isEqualTo: userId)
              .get();
          voted.addAll(votes.docs.map((d) => (d.data()['entryId'] ?? '').toString()));
        }
        return snap.docs
            .map((d) => EventModels.entry(d.data(), d.id, contestId, hasVoted: voted.contains(d.id)))
            .toList();
      });

  @override
  Future<ContestEntry> vote(String contestId, String entryId, String userId) => _guard(() async {
        final contestRef = _db.collection(FirestoreCollections.stoneCarvingContests).doc(contestId);
        final entryRef = contestRef.collection(FirestoreCollections.subContestEntries).doc(entryId);
        final voteRef = contestRef.collection(FirestoreCollections.subContestVotes).doc('${userId}_$entryId');
        await _db.runTransaction((tx) async {
          if ((await tx.get(voteRef)).exists) {
            throw const ServerException('Bạn đã bình chọn cho tác phẩm này rồi.');
          }
          tx.set(voteRef, {'userId': userId, 'entryId': entryId, 'createdAt': FieldValue.serverTimestamp()});
          tx.update(entryRef, {'voteCount': FieldValue.increment(1)});
        });
        final doc = await entryRef.get();
        return EventModels.entry(doc.data() ?? {}, doc.id, contestId, hasVoted: true);
      });

  /// Số chỗ đã đặt được Cloud Function `onBookingWrite` cập nhật phía máy chủ.
  @override
  Future<void> adjustBookedCount(String eventId, int delta) async {}
}
