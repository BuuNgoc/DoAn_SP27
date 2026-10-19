import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_management_entity.dart';
import '../../domain/usecases/booking_management_usecase.dart';

// Events
abstract class BookingManagementEvent extends Equatable {
  const BookingManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookingManagementEvent extends BookingManagementEvent {}

// States
abstract class BookingManagementState extends Equatable {
  const BookingManagementState();
  @override
  List<Object?> get props => [];
}

class BookingManagementInitial extends BookingManagementState {}
class BookingManagementLoading extends BookingManagementState {}
class BookingManagementLoaded extends BookingManagementState {
  final List<BookingEntity> items;
  const BookingManagementLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class BookingManagementError extends BookingManagementState {
  final String message;
  const BookingManagementError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class BookingManagementBloc extends Bloc<BookingManagementEvent, BookingManagementState> {
  final GetBookingManagementUseCase getItemsUseCase;

  BookingManagementBloc({required this.getItemsUseCase}) : super(BookingManagementInitial()) {
    on<LoadBookingManagementEvent>((event, emit) async {
      emit(BookingManagementLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(BookingManagementLoaded(items));
      } catch (e) {
        emit(BookingManagementError(e.toString()));
      }
    });
  }
}
