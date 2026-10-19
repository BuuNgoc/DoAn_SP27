import 'package:flutter/material.dart';
import '../../domain/entities/admin_portal_entity.dart';

/// [FE-17 -> FE-28] Card Widget for Admin Portal (CMS, VR/Audio, Events, Loyalty Rules, Analytics, RBAC, Audit Logs)
class AdminPortalCardWidget extends StatelessWidget {
  final AdminPortalEntity item;
  final VoidCallback? onTap;

  const AdminPortalCardWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
