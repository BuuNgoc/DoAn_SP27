import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/interactive_map_entity.dart';
import '../../domain/usecases/interactive_map_usecase.dart';

// Events
abstract class InteractiveMapEvent extends Equatable {
  const InteractiveMapEvent();
  @override
  List<Object?> get props => [];
}

class LoadInteractiveMapEvent extends InteractiveMapEvent {}

// States
abstract class InteractiveMapState extends Equatable {
  const InteractiveMapState();
  @override
  List<Object?> get props => [];
}

class InteractiveMapInitial extends InteractiveMapState {}
class InteractiveMapLoading extends InteractiveMapState {}
class InteractiveMapLoaded extends InteractiveMapState {
  final List<PoiLocationEntity> items;
  const InteractiveMapLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class InteractiveMapError extends InteractiveMapState {
  final String message;
  const InteractiveMapError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class InteractiveMapBloc extends Bloc<InteractiveMapEvent, InteractiveMapState> {
  final GetInteractiveMapUseCase getItemsUseCase;

  InteractiveMapBloc({required this.getItemsUseCase}) : super(InteractiveMapInitial()) {
    on<LoadInteractiveMapEvent>((event, emit) async {
      emit(InteractiveMapLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(InteractiveMapLoaded(items));
      } catch (e) {
        emit(InteractiveMapError(e.toString()));
      }
    });
  }
}
