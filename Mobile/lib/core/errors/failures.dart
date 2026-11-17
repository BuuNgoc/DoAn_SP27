import 'package:equatable/equatable.dart';

import '../localization/app_localizations.dart';
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
  const NetworkFailure([super.message = '']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = '']);
}

/// Chuyển mọi lỗi (Exception/Failure) thành thông điệp đa ngôn ngữ thân thiện.
String errorMessageOf(Object error) {
  if (error is NetworkFailure) {
    return error.message.isNotEmpty
        ? error.message
        : AppLocalizations.trStatic('core.network_error');
  }
  if (error is PermissionFailure) {
    return error.message.isNotEmpty
        ? error.message
        : AppLocalizations.trStatic('core.unauthorized_error');
  }
  if (error is Failure) return error.message;
  if (error is ServerException) return error.message;
  if (error is AuthException) return error.message;
  if (error is CacheException) return error.message;
  if (error is NetworkException) {
    return error.message.isNotEmpty
        ? error.message
        : AppLocalizations.trStatic('core.network_error');
  }
  if (error is PermissionException) {
    return error.message.isNotEmpty
        ? error.message
        : AppLocalizations.trStatic('core.unauthorized_error');
  }
  if (error is ArgumentError && error.message is String) return error.message as String;
  return AppLocalizations.trStatic('core.unexpected_error');
}
