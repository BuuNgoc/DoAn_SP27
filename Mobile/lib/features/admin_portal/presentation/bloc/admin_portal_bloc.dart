import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_portal_entity.dart';
import '../../domain/usecases/admin_portal_usecase.dart';

// Events
abstract class AdminPortalEvent extends Equatable {
  const AdminPortalEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminPortalEvent extends AdminPortalEvent {}

// States
abstract class AdminPortalState extends Equatable {
  const AdminPortalState();
  @override
  List<Object?> get props => [];
}

class AdminPortalInitial extends AdminPortalState {}
class AdminPortalLoading extends AdminPortalState {}
class AdminPortalLoaded extends AdminPortalState {
  final List<AdminPortalEntity> items;
  const AdminPortalLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class AdminPortalError extends AdminPortalState {
  final String message;
  const AdminPortalError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AdminPortalBloc extends Bloc<AdminPortalEvent, AdminPortalState> {
  final GetAdminPortalUseCase getItemsUseCase;

  AdminPortalBloc({required this.getItemsUseCase}) : super(AdminPortalInitial()) {
    on<LoadAdminPortalEvent>((event, emit) async {
      emit(AdminPortalLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(AdminPortalLoaded(items));
      } catch (e) {
        emit(AdminPortalError(e.toString()));
      }
    });
  }
}
