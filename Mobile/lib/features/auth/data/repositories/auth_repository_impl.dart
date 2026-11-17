import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';

/// [FE-01] Cài đặt AuthRepository tuân thủ Clean Architecture.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthFirebaseDataSource _dataSource;

  @override
  Stream<UserEntity?> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Đăng nhập thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.registerWithEmailPassword(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Đăng ký thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _dataSource.signInWithGoogle();
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Đăng nhập Google thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await _dataSource.resetPassword(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Gửi yêu cầu đặt lại mật khẩu thất bại.'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Đổi mật khẩu thất bại. Vui lòng kiểm tra lại.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUserProfile() async {
    try {
      final userModel = await _dataSource.getCurrentUserProfile();
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Không thể tải thông tin hồ sơ cá nhân.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? newAvatarFilePath,
  }) async {
    try {
      final updated = await _dataSource.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        newAvatarFilePath: newAvatarFilePath,
      );
      return Right(updated);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapFirebaseAuthError(e.code)));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Cập nhật hồ sơ thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Đăng xuất thất bại: ${e.toString()}'));
    }
  }

  /// Chuyển đổi mã lỗi FirebaseAuthException sang thông báo tiếng Việt chuẩn xác, lịch sự
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng kiểm tra lại.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ hoặc đã hết hạn.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký tài khoản. Vui lòng đăng nhập.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng đặt mật khẩu từ 6 ký tự trở lên.';
      case 'too-many-requests':
        return 'Bạn đã thao tác quá nhiều lần. Vui lòng thử lại sau ít phút.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.';
      case 'user-disabled':
        return 'Tài khoản của bạn đã bị vô hiệu hóa bởi Quản trị viên.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      default:
        return 'Đã xảy ra lỗi xác thực ($code). Vui lòng thử lại.';
    }
  }
}
