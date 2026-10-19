import 'package:flutter/material.dart';
import '../../domain/entities/vr360_audio_guide_entity.dart';

/// [FE-03] Card Widget for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
class Vr360AudioGuideCardWidget extends StatelessWidget {
  final Vr360AudioEntity item;
  final VoidCallback? onTap;

  const Vr360AudioGuideCardWidget({
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
