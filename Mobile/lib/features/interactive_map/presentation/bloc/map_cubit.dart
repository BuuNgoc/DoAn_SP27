import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/map_poi.dart';
import '../../domain/usecases/get_map_pois_usecase.dart';

class MapState extends Equatable {
  const MapState({
    this.status = ViewStatus.initial,
    this.pois = const [],
    this.activeLayers = const {...MapLayer.values},
    this.selected,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<MapPoi> pois;
  final Set<MapLayer> activeLayers;
  final MapPoi? selected;
  final String? errorMessage;

  List<MapPoi> get visiblePois => pois.where((p) => activeLayers.contains(p.layer)).toList();

  int countOf(MapLayer layer) => pois.where((p) => p.layer == layer).length;

  MapState copyWith({
    ViewStatus? status,
    List<MapPoi>? pois,
    Set<MapLayer>? activeLayers,
    MapPoi? selected,
    bool clearSelected = false,
    String? errorMessage,
  }) {
    return MapState(
      status: status ?? this.status,
      pois: pois ?? this.pois,
      activeLayers: activeLayers ?? this.activeLayers,
      selected: clearSelected ? null : (selected ?? this.selected),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, pois, activeLayers, selected, errorMessage];
}

/// [FE-04] Bản đồ tương tác: bật/tắt lớp, chọn POI.
class MapCubit extends Cubit<MapState> {
  MapCubit(this._getPois) : super(const MapState());

  final GetMapPoisUseCase _getPois;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final pois = await _getPois();
      emit(state.copyWith(status: ViewStatus.success, pois: pois));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void toggleLayer(MapLayer layer) {
    final next = {...state.activeLayers};
    if (!next.remove(layer)) next.add(layer);
    final keepSelected = state.selected != null && next.contains(state.selected!.layer);
    emit(state.copyWith(activeLayers: next, clearSelected: !keepSelected));
  }

  void showOnly(MapLayer layer) => emit(state.copyWith(activeLayers: {layer}, clearSelected: true));

  void showAll() => emit(state.copyWith(activeLayers: {...MapLayer.values}));

  void select(MapPoi poi) => emit(state.copyWith(selected: poi));

  void clearSelection() => emit(state.copyWith(clearSelected: true));
}
