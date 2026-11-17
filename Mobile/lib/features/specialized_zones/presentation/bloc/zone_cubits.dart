import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../../destination_discovery/domain/entities/destination.dart';
import '../../../destination_discovery/domain/usecases/destination_usecases.dart';
import '../../../events_workshops_craft/domain/entities/event_entities.dart';
import '../../../events_workshops_craft/domain/usecases/events_usecases.dart';
import '../../domain/entities/zone_entities.dart';
import '../../domain/usecases/zone_usecases.dart';

class ZoneState extends Equatable {
  const ZoneState({
    this.status = ViewStatus.initial,
    this.overview,
    this.events = const [],
    this.category,
    this.errorMessage,
  });

  final ViewStatus status;
  final ZoneOverview? overview;
  final List<EventWorkshop> events;
  final ZoneSpotCategory? category;
  final String? errorMessage;

  List<ZoneSpot> get visibleSpots =>
      (overview?.spots ?? const []).where((s) => category == null || s.category == category).toList();

  List<ZoneSpotCategory> get categories =>
      {for (final s in overview?.spots ?? const <ZoneSpot>[]) s.category}.toList();

  @override
  List<Object?> get props => [status, overview, events, category, errorMessage];
}

/// [FE-12, FE-13] Cubit cho trang phân khu An Thượng / Bãi biển.
class ZoneCubit extends Cubit<ZoneState> {
  ZoneCubit({required GetZoneOverviewUseCase getOverview, required GetEventsUseCase getEvents})
      : _getOverview = getOverview,
        _getEvents = getEvents,
        super(const ZoneState());

  final GetZoneOverviewUseCase _getOverview;
  final GetEventsUseCase _getEvents;

  Future<void> load(ZoneType zone) async {
    emit(const ZoneState(status: ViewStatus.loading));
    try {
      final overview = await _getOverview(zone);
      final all = await _getEvents();
      final events = all.where((e) => overview.relatedEventIds.contains(e.id)).toList();
      emit(ZoneState(status: ViewStatus.success, overview: overview, events: events));
    } catch (e) {
      emit(ZoneState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void selectCategory(ZoneSpotCategory? c) => emit(ZoneState(
        status: state.status,
        overview: state.overview,
        events: state.events,
        category: c == state.category ? null : c,
      ));
}

class AirportWelcomeState extends Equatable {
  const AirportWelcomeState({
    this.status = ViewStatus.initial,
    this.content,
    this.destinations = const [],
    this.events = const [],
    this.errorMessage,
  });

  final ViewStatus status;
  final AirportWelcomeContent? content;
  final List<Destination> destinations;
  final List<EventWorkshop> events;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, content, destinations, events, errorMessage];
}

/// [FE-14] Màn hình chào mừng du khách từ sân bay.
class AirportWelcomeCubit extends Cubit<AirportWelcomeState> {
  AirportWelcomeCubit({
    required GetAirportWelcomeUseCase getWelcome,
    required GetDestinationsUseCase getDestinations,
    required GetEventsUseCase getEvents,
  })  : _getWelcome = getWelcome,
        _getDestinations = getDestinations,
        _getEvents = getEvents,
        super(const AirportWelcomeState());

  final GetAirportWelcomeUseCase _getWelcome;
  final GetDestinationsUseCase _getDestinations;
  final GetEventsUseCase _getEvents;

  Future<void> load({String? campaignId}) async {
    emit(const AirportWelcomeState(status: ViewStatus.loading));
    try {
      final content = await _getWelcome(campaignId: campaignId);
      final results = await Future.wait([_getDestinations(), _getEvents()]);
      final destinations = (results[0] as List<Destination>)
          .where((d) => content.featuredDestinationIds.contains(d.id))
          .toList();
      final events =
          (results[1] as List<EventWorkshop>).where((e) => content.featuredEventIds.contains(e.id)).toList();
      emit(AirportWelcomeState(
        status: ViewStatus.success,
        content: content,
        destinations: destinations,
        events: events,
      ));
    } catch (e) {
      emit(AirportWelcomeState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}
