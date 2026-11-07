import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/event_entities.dart';
import '../../domain/usecases/events_usecases.dart';

// ─────────────────────────── Danh sách sự kiện ───────────────────────────

class EventListState extends Equatable {
  const EventListState({
    this.status = ViewStatus.initial,
    this.events = const [],
    this.kind,
    this.query = '',
    this.onlyAvailable = false,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<EventWorkshop> events;
  final EventKind? kind;
  final String query;
  final bool onlyAvailable;
  final String? errorMessage;

  List<EventWorkshop> get visible => onlyAvailable ? events.where((e) => !e.isFull).toList() : events;

  @override
  List<Object?> get props => [status, events, kind, query, onlyAvailable, errorMessage];
}

class EventListCubit extends Cubit<EventListState> {
  EventListCubit(this._getEvents) : super(const EventListState());

  final GetEventsUseCase _getEvents;

  Future<void> load({EventKind? kind, String? query}) async {
    final k = kind ?? state.kind;
    final q = query ?? state.query;
    emit(EventListState(
      status: ViewStatus.loading,
      events: state.events,
      kind: k,
      query: q,
      onlyAvailable: state.onlyAvailable,
    ));
    try {
      final events = await _getEvents(kind: k, query: q);
      emit(EventListState(
        status: ViewStatus.success,
        events: events,
        kind: k,
        query: q,
        onlyAvailable: state.onlyAvailable,
      ));
    } catch (e) {
      emit(EventListState(
        status: ViewStatus.failure,
        kind: k,
        query: q,
        onlyAvailable: state.onlyAvailable,
        errorMessage: errorMessageOf(e),
      ));
    }
  }

  void selectKind(EventKind? kind) {
    emit(EventListState(status: state.status, events: state.events, query: state.query, onlyAvailable: state.onlyAvailable, kind: kind));
    _reload(kind);
  }

  Future<void> _reload(EventKind? kind) async {
    try {
      final events = await _getEvents(kind: kind, query: state.query);
      emit(EventListState(
        status: ViewStatus.success,
        events: events,
        kind: kind,
        query: state.query,
        onlyAvailable: state.onlyAvailable,
      ));
    } catch (e) {
      emit(EventListState(status: ViewStatus.failure, kind: kind, query: state.query, errorMessage: errorMessageOf(e)));
    }
  }

  void search(String query) => load(query: query);

  void toggleOnlyAvailable() => emit(EventListState(
        status: state.status,
        events: state.events,
        kind: state.kind,
        query: state.query,
        onlyAvailable: !state.onlyAvailable,
      ));
}

// ─────────────────────────── Generic detail ───────────────────────────

class DetailState<T> extends Equatable {
  const DetailState({this.status = ViewStatus.initial, this.data, this.errorMessage});

  final ViewStatus status;
  final T? data;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, data, errorMessage];
}

class EventDetailCubit extends Cubit<DetailState<EventWorkshop>> {
  EventDetailCubit(this._get) : super(const DetailState());
  final GetEventDetailUseCase _get;

  Future<void> load(String id) async {
    emit(const DetailState(status: ViewStatus.loading));
    try {
      emit(DetailState(status: ViewStatus.success, data: await _get(id)));
    } catch (e) {
      emit(DetailState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}

class ArtisanProfile extends Equatable {
  const ArtisanProfile(this.artisan, this.workshops);
  final Artisan artisan;
  final List<EventWorkshop> workshops;

  @override
  List<Object?> get props => [artisan, workshops];
}

class ArtisanCubit extends Cubit<DetailState<ArtisanProfile>> {
  ArtisanCubit(this._getArtisan, this._getEvents) : super(const DetailState());
  final GetArtisanUseCase _getArtisan;
  final GetEventsUseCase _getEvents;

  Future<void> load(String id) async {
    emit(const DetailState(status: ViewStatus.loading));
    try {
      final artisan = await _getArtisan(id);
      final events = await _getEvents(kind: EventKind.workshop);
      final workshops = events.where((e) => e.artisanId == id || artisan.workshopIds.contains(e.id)).toList();
      emit(DetailState(status: ViewStatus.success, data: ArtisanProfile(artisan, workshops)));
    } catch (e) {
      emit(DetailState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}

// ─────────────────────────── Cuộc thi điêu khắc đá ───────────────────────────

class ContestState extends Equatable {
  const ContestState({
    this.status = ViewStatus.initial,
    this.contest,
    this.entries = const [],
    this.votingEntryId,
    this.errorMessage,
  });

  final ViewStatus status;
  final StoneCarvingContest? contest;

  /// Đã sắp xếp theo số phiếu giảm dần (bảng xếp hạng).
  final List<ContestEntry> entries;
  final String? votingEntryId;
  final String? errorMessage;

  int get totalVotes => entries.fold(0, (s, e) => s + e.voteCount);

  ContestState copyWith({
    ViewStatus? status,
    StoneCarvingContest? contest,
    List<ContestEntry>? entries,
    String? votingEntryId,
    bool clearVoting = false,
    String? errorMessage,
  }) =>
      ContestState(
        status: status ?? this.status,
        contest: contest ?? this.contest,
        entries: entries ?? this.entries,
        votingEntryId: clearVoting ? null : (votingEntryId ?? this.votingEntryId),
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, contest, entries, votingEntryId, errorMessage];
}

class ContestCubit extends Cubit<ContestState> {
  ContestCubit(this._getContest, this._getEntries, this._vote) : super(const ContestState());

  final GetActiveContestUseCase _getContest;
  final GetContestEntriesUseCase _getEntries;
  final VoteContestEntryUseCase _vote;

  Future<void> load({String? userId}) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final contest = await _getContest();
      final entries = await _getEntries(contest.id, userId: userId);
      emit(state.copyWith(status: ViewStatus.success, contest: contest, entries: entries));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  /// Trả về thông báo lỗi (null nếu thành công).
  Future<String?> vote(String entryId, String userId) async {
    final contest = state.contest;
    if (contest == null) return 'Không tìm thấy cuộc thi.';
    if (!contest.canVote) return 'Cuộc thi hiện không mở bình chọn.';
    emit(state.copyWith(votingEntryId: entryId));
    try {
      final updated = await _vote(contest.id, entryId, userId: userId);
      final entries = [for (final e in state.entries) e.id == entryId ? updated : e]
        ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
      emit(state.copyWith(entries: entries, clearVoting: true));
      return null;
    } catch (e) {
      emit(state.copyWith(clearVoting: true));
      return errorMessageOf(e);
    }
  }
}
