import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/destination.dart';
import '../../domain/usecases/destination_usecases.dart';

// ─────────────────────────── Danh sách / tìm kiếm / lọc ───────────────────────────

class DestinationListState extends Equatable {
  const DestinationListState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.category,
    this.query = '',
    this.errorMessage,
  });

  final ViewStatus status;
  final List<Destination> items;
  final DestinationCategory? category;
  final String query;
  final String? errorMessage;

  DestinationListState copyWith({
    ViewStatus? status,
    List<Destination>? items,
    DestinationCategory? category,
    bool clearCategory = false,
    String? query,
    String? errorMessage,
  }) {
    return DestinationListState(
      status: status ?? this.status,
      items: items ?? this.items,
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, category, query, errorMessage];
}

/// [FE-02] View list, search và filter by category.
class DestinationListCubit extends Cubit<DestinationListState> {
  DestinationListCubit(this._getDestinations) : super(const DestinationListState());

  final GetDestinationsUseCase _getDestinations;

  Future<void> load({DestinationCategory? category, String? query}) async {
    emit(state.copyWith(
      status: ViewStatus.loading,
      category: category,
      clearCategory: category == null,
      query: query ?? state.query,
    ));
    await _fetch();
  }

  Future<void> selectCategory(DestinationCategory? category) async {
    emit(state.copyWith(
      status: ViewStatus.loading,
      category: category,
      clearCategory: category == null || category == state.category,
    ));
    await _fetch();
  }

  Future<void> search(String query) async {
    emit(state.copyWith(query: query));
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final items = await _getDestinations(category: state.category, query: state.query);
      emit(state.copyWith(status: ViewStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}

// ─────────────────────────── Chi tiết điểm đến ───────────────────────────

class DestinationDetailState extends Equatable {
  const DestinationDetailState({this.status = ViewStatus.initial, this.destination, this.errorMessage});

  final ViewStatus status;
  final Destination? destination;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, destination, errorMessage];
}

class DestinationDetailCubit extends Cubit<DestinationDetailState> {
  DestinationDetailCubit(this._getDetail) : super(const DestinationDetailState());

  final GetDestinationDetailUseCase _getDetail;

  Future<void> load(String id) async {
    emit(const DestinationDetailState(status: ViewStatus.loading));
    try {
      emit(DestinationDetailState(status: ViewStatus.success, destination: await _getDetail(id)));
    } catch (e) {
      emit(DestinationDetailState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}

// ─────────────────────────── Yêu thích (offline) ───────────────────────────

/// State = tập id điểm đến đã lưu. Cubit toàn cục để trái tim đồng bộ mọi màn hình.
class FavoritesCubit extends Cubit<Set<String>> {
  FavoritesCubit({required GetFavoriteIdsUseCase getIds, required ToggleFavoriteUseCase toggle})
      : _getIds = getIds,
        _toggle = toggle,
        super(const {});

  final GetFavoriteIdsUseCase _getIds;
  final ToggleFavoriteUseCase _toggle;

  Future<void> load() async => emit(await _getIds());

  /// Trả về `true` nếu điểm đến vừa được thêm vào yêu thích.
  Future<bool> toggle(String id) async {
    final saved = await _toggle(id);
    final next = {...state};
    saved ? next.add(id) : next.remove(id);
    emit(next);
    return saved;
  }
}
