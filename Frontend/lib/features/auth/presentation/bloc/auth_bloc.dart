import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/usecases/auth_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoadAuthEvent extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthLoaded extends AuthState {
  final List<UserEntity> items;
  const AuthLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthUseCase getItemsUseCase;

  AuthBloc({required this.getItemsUseCase}) : super(AuthInitial()) {
    on<LoadAuthEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(AuthLoaded(items));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
