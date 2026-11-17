import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// [FE-01] Hợp đồng AuthRepository chuẩn Clean Architecture
abstract class AuthRepository {
  /// Luồng theo dõi trạng thái phiên đăng nhập người dùng theo thời gian thực
  Stream<UserEntity?> get authStateChanges;

  /// Đăng nhập bằng Email và Mật khẩu
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới bằng Email và Mật khẩu
  Future<Either<Failure, UserEntity>> registerWithEmailPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Đăng nhập nhanh bằng tài khoản Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Gửi email liên kết đặt lại mật khẩu
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Đổi mật khẩu tài khoản
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Lấy thông tin hồ sơ tài khoản hiện tại từ Firestore
  Future<Either<Failure, UserEntity>> getCurrentUserProfile();

  /// Cập nhật thông tin hồ sơ cá nhân và ảnh đại diện
  Future<Either<Failure, UserEntity>> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? newAvatarFilePath,
  });

  /// Đăng xuất khỏi phiên làm việc
  Future<Either<Failure, void>> logout();
}
