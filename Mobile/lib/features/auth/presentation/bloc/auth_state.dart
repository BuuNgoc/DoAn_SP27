import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthBlocState extends Equatable {
  const AuthBlocState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class AuthInitial extends AuthBlocState {
  const AuthInitial();
}

/// Đang xử lý tác vụ (hiển thị loading)
class AuthLoading extends AuthBlocState {
  const AuthLoading({this.message});
  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Đã xác thực thành công (có thông tin người dùng)
class AuthAuthenticated extends AuthBlocState {
  const AuthAuthenticated(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Chưa xác thực / Đã đăng xuất
class AuthUnauthenticated extends AuthBlocState {
  const AuthUnauthenticated();
}

/// Gửi liên kết đặt lại mật khẩu thành công
class AuthPasswordResetSent extends AuthBlocState {
  const AuthPasswordResetSent(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

/// Đổi mật khẩu thành công
class AuthPasswordChangedSuccess extends AuthBlocState {
  const AuthPasswordChangedSuccess();
}

/// Cập nhật hồ sơ cá nhân thành công
class AuthProfileUpdatedSuccess extends AuthBlocState {
  const AuthProfileUpdatedSuccess(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// Thao tác thất bại kèm thông điệp lỗi tiếng Việt
class AuthError extends AuthBlocState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
