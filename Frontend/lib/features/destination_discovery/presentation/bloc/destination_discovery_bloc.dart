import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/destination_discovery_entity.dart';
import '../../domain/usecases/destination_discovery_usecase.dart';

// Events
abstract class DestinationDiscoveryEvent extends Equatable {
  const DestinationDiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class LoadDestinationDiscoveryEvent extends DestinationDiscoveryEvent {}

// States
abstract class DestinationDiscoveryState extends Equatable {
  const DestinationDiscoveryState();
  @override
  List<Object?> get props => [];
}

class DestinationDiscoveryInitial extends DestinationDiscoveryState {}
class DestinationDiscoveryLoading extends DestinationDiscoveryState {}
class DestinationDiscoveryLoaded extends DestinationDiscoveryState {
  final List<DestinationEntity> items;
  const DestinationDiscoveryLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class DestinationDiscoveryError extends DestinationDiscoveryState {
  final String message;
  const DestinationDiscoveryError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class DestinationDiscoveryBloc extends Bloc<DestinationDiscoveryEvent, DestinationDiscoveryState> {
  final GetDestinationDiscoveryUseCase getItemsUseCase;

  DestinationDiscoveryBloc({required this.getItemsUseCase}) : super(DestinationDiscoveryInitial()) {
    on<LoadDestinationDiscoveryEvent>((event, emit) async {
      emit(DestinationDiscoveryLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(DestinationDiscoveryLoaded(items));
      } catch (e) {
        emit(DestinationDiscoveryError(e.toString()));
      }
    });
  }
}
