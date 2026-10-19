import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/specialized_zones_entity.dart';
import '../../domain/usecases/specialized_zones_usecase.dart';

// Events
abstract class SpecializedZonesEvent extends Equatable {
  const SpecializedZonesEvent();
  @override
  List<Object?> get props => [];
}

class LoadSpecializedZonesEvent extends SpecializedZonesEvent {}

// States
abstract class SpecializedZonesState extends Equatable {
  const SpecializedZonesState();
  @override
  List<Object?> get props => [];
}

class SpecializedZonesInitial extends SpecializedZonesState {}
class SpecializedZonesLoading extends SpecializedZonesState {}
class SpecializedZonesLoaded extends SpecializedZonesState {
  final List<ZoneEntity> items;
  const SpecializedZonesLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class SpecializedZonesError extends SpecializedZonesState {
  final String message;
  const SpecializedZonesError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class SpecializedZonesBloc extends Bloc<SpecializedZonesEvent, SpecializedZonesState> {
  final GetSpecializedZonesUseCase getItemsUseCase;

  SpecializedZonesBloc({required this.getItemsUseCase}) : super(SpecializedZonesInitial()) {
    on<LoadSpecializedZonesEvent>((event, emit) async {
      emit(SpecializedZonesLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(SpecializedZonesLoaded(items));
      } catch (e) {
        emit(SpecializedZonesError(e.toString()));
      }
    });
  }
}
