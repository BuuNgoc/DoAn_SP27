import 'package:flutter/material.dart';
import '../../domain/entities/events_workshops_craft_entity.dart';

/// [FE-06, FE-15, FE-16] Card Widget for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class EventsWorkshopsCraftCardWidget extends StatelessWidget {
  final EventCraftEntity item;
  final VoidCallback? onTap;

  const EventsWorkshopsCraftCardWidget({
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
