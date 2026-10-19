import 'package:flutter/material.dart';
import '../../domain/entities/auth_entity.dart';

/// [FE-01] Card Widget for Authentication (Register, Login, Reset/Change Password, Profile)
class AuthCardWidget extends StatelessWidget {
  final UserEntity item;
  final VoidCallback? onTap;

  const AuthCardWidget({
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
