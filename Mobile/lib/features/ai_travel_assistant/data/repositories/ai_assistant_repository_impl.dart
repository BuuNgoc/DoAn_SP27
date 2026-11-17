import 'dart:typed_data';

import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  AiAssistantRepositoryImpl(this._remote);

  final AiRemoteDataSource _remote;

  @override
  Future<LandmarkRecognition> recognizeLandmark(Uint8List imageBytes) => _remote.recognizeLandmark(imageBytes);

  @override
  Future<GeneratedItinerary> generateItinerary(ItineraryRequest request) => _remote.generateItinerary(request);

  @override
  Future<ChatMessage> sendChatMessage(List<ChatMessage> history, String message) => _remote.chat(history, message);
}
