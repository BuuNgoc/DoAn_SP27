import '../entities/event_entities.dart';

/// [FE-06, FE-15, FE-16] Hợp đồng dữ liệu sự kiện, nghệ nhân, cuộc thi.
abstract class EventsRepository {
  Future<List<EventWorkshop>> getEvents({EventKind? kind, String? query});
  Future<EventWorkshop> getEventById(String id);

  Future<List<Artisan>> getArtisans();
  Future<Artisan> getArtisanById(String id);

  Future<StoneCarvingContest> getActiveContest();
  Future<List<ContestEntry>> getContestEntries(String contestId, {required String? userId});
  Future<ContestEntry> getContestEntry(String contestId, String entryId, {required String? userId});

  /// Bình chọn (1 lượt/tác phẩm/người dùng). Trả về tác phẩm sau cập nhật.
  Future<ContestEntry> voteEntry(String contestId, String entryId, {required String userId});
}
