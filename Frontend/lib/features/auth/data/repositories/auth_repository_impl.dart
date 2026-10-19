import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// [FE-01] Repository Implementation for Authentication (Register, Login, Reset/Change Password, Profile)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<UserEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
