import 'ai_travel_assistant_entity.dart';

/// [FE-05 & RAG] Domain Repository Interface for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
abstract class AiTravelAssistantRepository {
  Future<List<AiAssistantEntity>> getItems();
  Future<AiAssistantEntity> getItemById(String id);
}
