import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_travel_assistant_entity.dart';
import '../../domain/usecases/ai_travel_assistant_usecase.dart';

// Events
abstract class AiTravelAssistantEvent extends Equatable {
  const AiTravelAssistantEvent();
  @override
  List<Object?> get props => [];
}

class LoadAiTravelAssistantEvent extends AiTravelAssistantEvent {}

// States
abstract class AiTravelAssistantState extends Equatable {
  const AiTravelAssistantState();
  @override
  List<Object?> get props => [];
}

class AiTravelAssistantInitial extends AiTravelAssistantState {}
class AiTravelAssistantLoading extends AiTravelAssistantState {}
class AiTravelAssistantLoaded extends AiTravelAssistantState {
  final List<AiAssistantEntity> items;
  const AiTravelAssistantLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class AiTravelAssistantError extends AiTravelAssistantState {
  final String message;
  const AiTravelAssistantError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AiTravelAssistantBloc extends Bloc<AiTravelAssistantEvent, AiTravelAssistantState> {
  final GetAiTravelAssistantUseCase getItemsUseCase;

  AiTravelAssistantBloc({required this.getItemsUseCase}) : super(AiTravelAssistantInitial()) {
    on<LoadAiTravelAssistantEvent>((event, emit) async {
      emit(AiTravelAssistantLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(AiTravelAssistantLoaded(items));
      } catch (e) {
        emit(AiTravelAssistantError(e.toString()));
      }
    });
  }
}
