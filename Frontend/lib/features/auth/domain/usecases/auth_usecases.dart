import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailPasswordUseCase {
  const LoginWithEmailPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) =>
      _repository.loginWithEmailPassword(
        email: email.trim(),
        password: password,
      );
}

class RegisterWithEmailPasswordUseCase {
  const RegisterWithEmailPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) =>
      _repository.registerWithEmailPassword(
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        password: password,
      );
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call() => _repository.signInWithGoogle();
}

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call({required String email}) =>
      _repository.resetPassword(email: email.trim());
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}

class GetCurrentUserProfileUseCase {
  const GetCurrentUserProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call() => _repository.getCurrentUserProfile();
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String phoneNumber,
    String? newAvatarFilePath,
  }) =>
      _repository.updateProfile(
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        newAvatarFilePath: newAvatarFilePath,
      );
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call() => _repository.logout();
}

/// Backwards compatibility aliases
typedef LoginUseCase = LoginWithEmailPasswordUseCase;
typedef RegisterUseCase = RegisterWithEmailPasswordUseCase;
typedef GetCurrentUserUseCase = GetCurrentUserProfileUseCase;
