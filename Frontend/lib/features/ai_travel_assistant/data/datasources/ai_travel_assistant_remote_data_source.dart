import '../models/ai_travel_assistant_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-05 & RAG] Remote DataSource for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
abstract class AiTravelAssistantRemoteDataSource {
  Future<List<AiAssistantModel>> fetchItems();
  Future<AiAssistantModel> fetchItemById(String id);
}

class AiTravelAssistantRemoteDataSourceImpl implements AiTravelAssistantRemoteDataSource {
  final FirestoreService firestoreService;

  AiTravelAssistantRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<AiAssistantModel>> fetchItems() async {
    // Stub implementation for FE-05 & RAG
    return [];
  }

  @override
  Future<AiAssistantModel> fetchItemById(String id) async {
    // Stub implementation for FE-05 & RAG
    return AiAssistantModel(id: id, title: 'Item $id');
  }
}
