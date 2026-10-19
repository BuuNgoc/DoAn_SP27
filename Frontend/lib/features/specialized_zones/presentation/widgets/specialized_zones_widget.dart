import 'package:flutter/material.dart';
import '../../domain/entities/specialized_zones_entity.dart';

/// [FE-12, FE-13, FE-14] Card Widget for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
class SpecializedZonesCardWidget extends StatelessWidget {
  final ZoneEntity item;
  final VoidCallback? onTap;

  const SpecializedZonesCardWidget({
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
