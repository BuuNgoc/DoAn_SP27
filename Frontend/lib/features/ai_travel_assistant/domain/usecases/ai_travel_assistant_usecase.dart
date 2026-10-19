import '../entities/ai_travel_assistant_entity.dart';
import '../repositories/ai_travel_assistant_repository.dart';

/// [FE-05 & RAG] Primary UseCase for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class GetAiTravelAssistantUseCase {
  final AiTravelAssistantRepository repository;

  GetAiTravelAssistantUseCase(this.repository);

  Future<List<AiAssistantEntity>> execute() async {
    return await repository.getItems();
  }
}
