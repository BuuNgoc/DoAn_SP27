import '../entities/admin_portal_entity.dart';
import '../repositories/admin_portal_repository.dart';

/// [FE-17 -> FE-28] Primary UseCase for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
class GetAdminPortalUseCase {
  final AdminPortalRepository repository;

  GetAdminPortalUseCase(this.repository);

  Future<List<AdminPortalEntity>> execute() async {
    return await repository.getItems();
  }
}
