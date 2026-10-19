import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/qr_checkin_loyalty_entity.dart';
import '../../domain/usecases/qr_checkin_loyalty_usecase.dart';

// Events
abstract class QrCheckinLoyaltyEvent extends Equatable {
  const QrCheckinLoyaltyEvent();
  @override
  List<Object?> get props => [];
}

class LoadQrCheckinLoyaltyEvent extends QrCheckinLoyaltyEvent {}

// States
abstract class QrCheckinLoyaltyState extends Equatable {
  const QrCheckinLoyaltyState();
  @override
  List<Object?> get props => [];
}

class QrCheckinLoyaltyInitial extends QrCheckinLoyaltyState {}
class QrCheckinLoyaltyLoading extends QrCheckinLoyaltyState {}
class QrCheckinLoyaltyLoaded extends QrCheckinLoyaltyState {
  final List<CheckinLoyaltyEntity> items;
  const QrCheckinLoyaltyLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class QrCheckinLoyaltyError extends QrCheckinLoyaltyState {
  final String message;
  const QrCheckinLoyaltyError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class QrCheckinLoyaltyBloc extends Bloc<QrCheckinLoyaltyEvent, QrCheckinLoyaltyState> {
  final GetQrCheckinLoyaltyUseCase getItemsUseCase;

  QrCheckinLoyaltyBloc({required this.getItemsUseCase}) : super(QrCheckinLoyaltyInitial()) {
    on<LoadQrCheckinLoyaltyEvent>((event, emit) async {
      emit(QrCheckinLoyaltyLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(QrCheckinLoyaltyLoaded(items));
      } catch (e) {
        emit(QrCheckinLoyaltyError(e.toString()));
      }
    });
  }
}
