import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

enum AuthStatus { unknown, authenticated, guest }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserEntity? user;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool clearUser = false,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, errorMessage];
}

/// [FE-01] Quản lý phiên đăng nhập (Cubit tương thích cho toàn bộ màn hình hệ thống).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required GetCurrentUserProfileUseCase getCurrentUser,
    required LoginWithEmailPasswordUseCase login,
    required RegisterWithEmailPasswordUseCase register,
    required SignInWithGoogleUseCase signInWithGoogle,
    required ResetPasswordUseCase resetPassword,
    required ChangePasswordUseCase changePassword,
    required UpdateProfileUseCase updateProfile,
    required LogoutUseCase logout,
  })  : _getCurrentUser = getCurrentUser,
        _login = login,
        _register = register,
        _signInWithGoogle = signInWithGoogle,
        _resetPassword = resetPassword,
        _changePassword = changePassword,
        _updateProfile = updateProfile,
        _logout = logout,
        super(const AuthState());

  final GetCurrentUserProfileUseCase _getCurrentUser;
  final LoginWithEmailPasswordUseCase _login;
  final RegisterWithEmailPasswordUseCase _register;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final ResetPasswordUseCase _resetPassword;
  final ChangePasswordUseCase _changePassword;
  final UpdateProfileUseCase _updateProfile;
  final LogoutUseCase _logout;

  Future<void> checkSession() async {
    final result = await _getCurrentUser();
    result.fold(
      (_) => emit(const AuthState(status: AuthStatus.guest)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<String?> login(String email, String password) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _login(email: email, password: password);
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return failure.message;
      },
      (user) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        return null;
      },
    );
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
    String nationality = 'Việt Nam',
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _register(
      fullName: fullName,
      email: email,
      phoneNumber: phone,
      password: password,
    );
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return failure.message;
      },
      (user) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        return null;
      },
    );
  }

  Future<String?> signInWithGoogle() async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _signInWithGoogle();
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return failure.message;
      },
      (user) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        return null;
      },
    );
  }

  Future<String?> resetPassword(String email) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _resetPassword(email: email);
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  Future<String?> updateProfile(UserEntity user, {String? newAvatarFilePath}) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    final result = await _updateProfile(
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      newAvatarFilePath: newAvatarFilePath,
    );
    emit(state.copyWith(isSubmitting: false));
    return result.fold(
      (failure) => failure.message,
      (updated) {
        emit(state.copyWith(user: updated));
        return null;
      },
    );
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthState(status: AuthStatus.guest));
  }
}
