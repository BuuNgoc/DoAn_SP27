import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/vr360_audio_guide_entity.dart';
import '../../domain/usecases/vr360_audio_guide_usecase.dart';

// Events
abstract class Vr360AudioGuideEvent extends Equatable {
  const Vr360AudioGuideEvent();
  @override
  List<Object?> get props => [];
}

class LoadVr360AudioGuideEvent extends Vr360AudioGuideEvent {}

// States
abstract class Vr360AudioGuideState extends Equatable {
  const Vr360AudioGuideState();
  @override
  List<Object?> get props => [];
}

class Vr360AudioGuideInitial extends Vr360AudioGuideState {}
class Vr360AudioGuideLoading extends Vr360AudioGuideState {}
class Vr360AudioGuideLoaded extends Vr360AudioGuideState {
  final List<Vr360AudioEntity> items;
  const Vr360AudioGuideLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class Vr360AudioGuideError extends Vr360AudioGuideState {
  final String message;
  const Vr360AudioGuideError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class Vr360AudioGuideBloc extends Bloc<Vr360AudioGuideEvent, Vr360AudioGuideState> {
  final GetVr360AudioGuideUseCase getItemsUseCase;

  Vr360AudioGuideBloc({required this.getItemsUseCase}) : super(Vr360AudioGuideInitial()) {
    on<LoadVr360AudioGuideEvent>((event, emit) async {
      emit(Vr360AudioGuideLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(Vr360AudioGuideLoaded(items));
      } catch (e) {
        emit(Vr360AudioGuideError(e.toString()));
      }
    });
  }
}
