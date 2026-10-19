import 'package:equatable/equatable.dart';

/// [FE-17 -> FE-28] Entity for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
class AdminPortalEntity extends Equatable {
  final String id;
  final String title;

  const AdminPortalEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
