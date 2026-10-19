import 'auth_entity.dart';

/// [FE-01] Domain Repository Interface for Authentication (Register, Login, Reset/Change Password, Profile)
abstract class AuthRepository {
  Future<List<UserEntity>> getItems();
  Future<UserEntity> getItemById(String id);
}
