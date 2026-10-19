import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// [FE-01] Primary UseCase for Authentication (Register, Login, Reset/Change Password, Profile)
class GetAuthUseCase {
  final AuthRepository repository;

  GetAuthUseCase(this.repository);

  Future<List<UserEntity>> execute() async {
    return await repository.getItems();
  }
}
