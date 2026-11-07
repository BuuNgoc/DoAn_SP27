import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Base Failure class for Clean Architecture
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Bạn không có quyền thực hiện thao tác này.']);
}

/// Chuyển mọi lỗi (Exception/Failure) thành thông điệp tiếng Việt thân thiện.
String errorMessageOf(Object error) {
  if (error is Failure) return error.message;
  if (error is ServerException) return error.message;
  if (error is AuthException) return error.message;
  if (error is CacheException) return error.message;
  if (error is NetworkException) return error.message;
  if (error is PermissionException) return error.message;
  if (error is ArgumentError && error.message is String) return error.message as String;
  return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
}
