/// Base and concrete exceptions
class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});
  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = '']);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = '']);
}
