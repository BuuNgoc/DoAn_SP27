import 'package:flutter/material.dart';
import '../../domain/entities/interactive_map_entity.dart';

/// [FE-04] Card Widget for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
class InteractiveMapCardWidget extends StatelessWidget {
  final PoiLocationEntity item;
  final VoidCallback? onTap;

  const InteractiveMapCardWidget({
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
