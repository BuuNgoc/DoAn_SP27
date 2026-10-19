import '../../domain/entities/admin_portal_entity.dart';

/// [FE-17 -> FE-28] Data Model with Firestore serialization for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
class AdminPortalModel extends AdminPortalEntity {
  const AdminPortalModel({
    required super.id,
    required super.title,
  });

  factory AdminPortalModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AdminPortalModel(
      id: documentId,
      title: data['title'] as String? ?? data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
    };
  }
}
