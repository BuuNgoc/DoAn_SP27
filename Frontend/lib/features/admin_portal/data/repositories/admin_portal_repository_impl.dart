import '../../domain/entities/admin_portal_entity.dart';
import '../../domain/repositories/admin_portal_repository.dart';
import '../datasources/admin_portal_remote_data_source.dart';

/// [FE-17 -> FE-28] Repository Implementation for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
class AdminPortalRepositoryImpl implements AdminPortalRepository {
  final AdminPortalRemoteDataSource remoteDataSource;

  AdminPortalRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AdminPortalEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<AdminPortalEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
