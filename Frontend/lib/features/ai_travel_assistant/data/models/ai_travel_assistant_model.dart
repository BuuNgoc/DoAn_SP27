import '../../domain/entities/ai_travel_assistant_entity.dart';

/// [FE-05 & RAG] Data Model with Firestore serialization for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class AiAssistantModel extends AiAssistantEntity {
  const AiAssistantModel({
    required super.id,
    required super.title,
  });

  factory AiAssistantModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AiAssistantModel(
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
