import 'admin_portal_entity.dart';

/// [FE-17 -> FE-28] Domain Repository Interface for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
abstract class AdminPortalRepository {
  Future<List<AdminPortalEntity>> getItems();
  Future<AdminPortalEntity> getItemById(String id);
}
