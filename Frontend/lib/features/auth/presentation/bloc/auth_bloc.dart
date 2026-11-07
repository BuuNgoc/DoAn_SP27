import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// [FE-01] AuthBloc quản lý luồng trạng thái xác thực toàn hệ thống
class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  AuthBloc({
    required GetCurrentUserProfileUseCase getCurrentUser,
    required LoginWithEmailPasswordUseCase loginWithEmail,
    required RegisterWithEmailPasswordUseCase registerWithEmail,
    required SignInWithGoogleUseCase signInWithGoogle,
    required ResetPasswordUseCase resetPassword,
    required ChangePasswordUseCase changePassword,
    required UpdateProfileUseCase updateProfile,
    required LogoutUseCase logout,
  })  : _getCurrentUser = getCurrentUser,
        _loginWithEmail = loginWithEmail,
        _registerWithEmail = registerWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _resetPassword = resetPassword,
        _changePassword = changePassword,
        _updateProfile = updateProfile,
        _logout = logout,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginWithEmailSubmitted>(_onLoginSubmitted);
    on<AuthRegisterWithEmailSubmitted>(_onRegisterSubmitted);
    on<AuthGoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthChangePasswordSubmitted>(_onChangePasswordSubmitted);
    on<AuthUpdateProfileSubmitted>(_onUpdateProfileSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentUserProfileUseCase _getCurrentUser;
  final LoginWithEmailPasswordUseCase _loginWithEmail;
  final RegisterWithEmailPasswordUseCase _registerWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final ResetPasswordUseCase _resetPassword;
  final ChangePasswordUseCase _changePassword;
  final UpdateProfileUseCase _updateProfile;
  final LogoutUseCase _logout;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    final result = await _getCurrentUser();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginWithEmailSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang xác thực thông tin đăng nhập...'));
    final result = await _loginWithEmail(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterWithEmailSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang tạo tài khoản mới...'));
    final result = await _registerWithEmail(
      fullName: event.fullName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onGoogleSignInSubmitted(
    AuthGoogleSignInSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang kết nối tài khoản Google...'));
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang gửi email đặt lại mật khẩu...'));
    final result = await _resetPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent(event.email)),
    );
  }

  Future<void> _onChangePasswordSubmitted(
    AuthChangePasswordSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang cập nhật mật khẩu mới...'));
    final result = await _changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordChangedSuccess()),
    );
  }

  Future<void> _onUpdateProfileSubmitted(
    AuthUpdateProfileSubmitted event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang lưu thông tin hồ sơ...'));
    final result = await _updateProfile(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      newAvatarFilePath: event.newAvatarFilePath,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthProfileUpdatedSuccess(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(const AuthLoading(message: 'Đang đăng xuất...'));
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
