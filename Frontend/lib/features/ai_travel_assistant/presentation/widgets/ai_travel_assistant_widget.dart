import 'package:flutter/material.dart';
import '../../domain/entities/ai_travel_assistant_entity.dart';

/// [FE-05 & RAG] Card Widget for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class AiTravelAssistantCardWidget extends StatelessWidget {
  final AiAssistantEntity item;
  final VoidCallback? onTap;

  const AiTravelAssistantCardWidget({
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
