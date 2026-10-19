import '../models/admin_portal_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-17 -> FE-28] Remote DataSource for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
abstract class AdminPortalRemoteDataSource {
  Future<List<AdminPortalModel>> fetchItems();
  Future<AdminPortalModel> fetchItemById(String id);
}

class AdminPortalRemoteDataSourceImpl implements AdminPortalRemoteDataSource {
  final FirestoreService firestoreService;

  AdminPortalRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<AdminPortalModel>> fetchItems() async {
    // Stub implementation for FE-17 -> FE-28
    return [];
  }

  @override
  Future<AdminPortalModel> fetchItemById(String id) async {
    // Stub implementation for FE-17 -> FE-28
    return AdminPortalModel(id: id, title: 'Item $id');
  }
}
