import '../entities/event_entities.dart';
import '../repositories/events_repository.dart';

class GetEventsUseCase {
  const GetEventsUseCase(this._r);
  final EventsRepository _r;
  Future<List<EventWorkshop>> call({EventKind? kind, String? query}) => _r.getEvents(kind: kind, query: query);
}

class GetEventDetailUseCase {
  const GetEventDetailUseCase(this._r);
  final EventsRepository _r;
  Future<EventWorkshop> call(String id) => _r.getEventById(id);
}

class GetArtisanUseCase {
  const GetArtisanUseCase(this._r);
  final EventsRepository _r;
  Future<Artisan> call(String id) => _r.getArtisanById(id);
}

class GetArtisansUseCase {
  const GetArtisansUseCase(this._r);
  final EventsRepository _r;
  Future<List<Artisan>> call() => _r.getArtisans();
}

class GetActiveContestUseCase {
  const GetActiveContestUseCase(this._r);
  final EventsRepository _r;
  Future<StoneCarvingContest> call() => _r.getActiveContest();
}

class GetContestEntriesUseCase {
  const GetContestEntriesUseCase(this._r);
  final EventsRepository _r;
  Future<List<ContestEntry>> call(String contestId, {String? userId}) =>
      _r.getContestEntries(contestId, userId: userId);
}

class GetContestEntryUseCase {
  const GetContestEntryUseCase(this._r);
  final EventsRepository _r;
  Future<ContestEntry> call(String contestId, String entryId, {String? userId}) =>
      _r.getContestEntry(contestId, entryId, userId: userId);
}

class VoteContestEntryUseCase {
  const VoteContestEntryUseCase(this._r);
  final EventsRepository _r;
  Future<ContestEntry> call(String contestId, String entryId, {required String userId}) =>
      _r.voteEntry(contestId, entryId, userId: userId);
}
