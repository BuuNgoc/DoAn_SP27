import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Kiểm tra trạng thái phiên làm việc hiện tại
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Đăng nhập bằng Email & Mật khẩu
class AuthLoginWithEmailSubmitted extends AuthEvent {
  const AuthLoginWithEmailSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Đăng ký tài khoản mới bằng Email & Mật khẩu
class AuthRegisterWithEmailSubmitted extends AuthEvent {
  const AuthRegisterWithEmailSubmitted({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });

  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password];
}

/// Đăng nhập bằng tài khoản Google
class AuthGoogleSignInSubmitted extends AuthEvent {
  const AuthGoogleSignInSubmitted();
}

/// Yêu cầu gửi email đặt lại mật khẩu
class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Thay đổi mật khẩu
class AuthChangePasswordSubmitted extends AuthEvent {
  const AuthChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Cập nhật thông tin hồ sơ cá nhân và ảnh đại diện
class AuthUpdateProfileSubmitted extends AuthEvent {
  const AuthUpdateProfileSubmitted({
    required this.fullName,
    required this.phoneNumber,
    this.newAvatarFilePath,
  });

  final String fullName;
  final String phoneNumber;
  final String? newAvatarFilePath;

  @override
  List<Object?> get props => [fullName, phoneNumber, newAvatarFilePath];
}

/// Đăng xuất khỏi hệ thống
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
