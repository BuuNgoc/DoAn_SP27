import 'package:flutter/material.dart';
import '../../domain/entities/destination_discovery_entity.dart';

/// [FE-02] Card Widget for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
class DestinationDiscoveryCardWidget extends StatelessWidget {
  final DestinationEntity item;
  final VoidCallback? onTap;

  const DestinationDiscoveryCardWidget({
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
