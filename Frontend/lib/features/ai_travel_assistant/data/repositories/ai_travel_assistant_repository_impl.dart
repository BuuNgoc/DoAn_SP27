import '../../domain/entities/ai_travel_assistant_entity.dart';
import '../../domain/repositories/ai_travel_assistant_repository.dart';
import '../datasources/ai_travel_assistant_remote_data_source.dart';

/// [FE-05 & RAG] Repository Implementation for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class AiTravelAssistantRepositoryImpl implements AiTravelAssistantRepository {
  final AiTravelAssistantRemoteDataSource remoteDataSource;

  AiTravelAssistantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AiAssistantEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<AiAssistantEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
