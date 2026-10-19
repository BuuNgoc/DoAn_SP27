import '../models/auth_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-01] Remote DataSource for Authentication (Register, Login, Reset/Change Password, Profile)
abstract class AuthRemoteDataSource {
  Future<List<UserModel>> fetchItems();
  Future<UserModel> fetchItemById(String id);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirestoreService firestoreService;

  AuthRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<UserModel>> fetchItems() async {
    // Stub implementation for FE-01
    return [];
  }

  @override
  Future<UserModel> fetchItemById(String id) async {
    // Stub implementation for FE-01
    return UserModel(id: id, title: 'Item $id');
  }
}
