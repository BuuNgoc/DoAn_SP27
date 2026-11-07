import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../domain/entities/event_entities.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_data_source.dart';

class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._remote);

  final EventsRemoteDataSource _remote;

  /// Cho phân hệ đặt chỗ (FE-07) giữ/trả chỗ.
  EventsRemoteDataSource get remote => _remote;

  @override
  Future<List<EventWorkshop>> getEvents({EventKind? kind, String? query}) async {
    final q = normalizeVietnamese(query ?? '');
    final all = await _remote.fetchEvents();
    final filtered = all.where((e) {
      final okKind = kind == null || e.kind == kind;
      final okQuery = q.isEmpty ||
          normalizeVietnamese(e.title).contains(q) ||
          normalizeVietnamese(e.category).contains(q) ||
          normalizeVietnamese(e.venue).contains(q);
      return okKind && okQuery;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return filtered;
  }

  @override
  Future<EventWorkshop> getEventById(String id) async {
    final all = await _remote.fetchEvents();
    return all.firstWhere((e) => e.id == id, orElse: () => throw const ServerException('Không tìm thấy sự kiện.'));
  }

  @override
  Future<List<Artisan>> getArtisans() => _remote.fetchArtisans();

  @override
  Future<Artisan> getArtisanById(String id) async {
    final all = await _remote.fetchArtisans();
    return all.firstWhere((a) => a.id == id, orElse: () => throw const ServerException('Không tìm thấy nghệ nhân.'));
  }

  @override
  Future<StoneCarvingContest> getActiveContest() => _remote.fetchActiveContest();

  @override
  Future<List<ContestEntry>> getContestEntries(String contestId, {required String? userId}) async {
    final entries = await _remote.fetchEntries(contestId, userId);
    return entries..sort((a, b) => b.voteCount.compareTo(a.voteCount));
  }

  @override
  Future<ContestEntry> getContestEntry(String contestId, String entryId, {required String? userId}) async {
    final entries = await _remote.fetchEntries(contestId, userId);
    return entries.firstWhere(
      (e) => e.id == entryId,
      orElse: () => throw const ServerException('Không tìm thấy tác phẩm.'),
    );
  }

  @override
  Future<ContestEntry> voteEntry(String contestId, String entryId, {required String userId}) =>
      _remote.vote(contestId, entryId, userId);
}
