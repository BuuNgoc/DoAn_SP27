import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/events_workshops_craft_entity.dart';
import '../../domain/usecases/events_workshops_craft_usecase.dart';

// Events
abstract class EventsWorkshopsCraftEvent extends Equatable {
  const EventsWorkshopsCraftEvent();
  @override
  List<Object?> get props => [];
}

class LoadEventsWorkshopsCraftEvent extends EventsWorkshopsCraftEvent {}

// States
abstract class EventsWorkshopsCraftState extends Equatable {
  const EventsWorkshopsCraftState();
  @override
  List<Object?> get props => [];
}

class EventsWorkshopsCraftInitial extends EventsWorkshopsCraftState {}
class EventsWorkshopsCraftLoading extends EventsWorkshopsCraftState {}
class EventsWorkshopsCraftLoaded extends EventsWorkshopsCraftState {
  final List<EventCraftEntity> items;
  const EventsWorkshopsCraftLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class EventsWorkshopsCraftError extends EventsWorkshopsCraftState {
  final String message;
  const EventsWorkshopsCraftError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class EventsWorkshopsCraftBloc extends Bloc<EventsWorkshopsCraftEvent, EventsWorkshopsCraftState> {
  final GetEventsWorkshopsCraftUseCase getItemsUseCase;

  EventsWorkshopsCraftBloc({required this.getItemsUseCase}) : super(EventsWorkshopsCraftInitial()) {
    on<LoadEventsWorkshopsCraftEvent>((event, emit) async {
      emit(EventsWorkshopsCraftLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(EventsWorkshopsCraftLoaded(items));
      } catch (e) {
        emit(EventsWorkshopsCraftError(e.toString()));
      }
    });
  }
}
