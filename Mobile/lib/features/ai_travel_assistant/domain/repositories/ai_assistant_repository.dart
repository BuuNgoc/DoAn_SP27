import 'dart:typed_data';

import '../entities/ai_entities.dart';

/// [FE-05] Hợp đồng dịch vụ AI: nhận diện ảnh, RAG lịch trình, trò chuyện.
abstract class AiAssistantRepository {
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes);

  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request);

  Future<ChatMessage> sendChatMessage(List<ChatMessage> history, String message);
}
