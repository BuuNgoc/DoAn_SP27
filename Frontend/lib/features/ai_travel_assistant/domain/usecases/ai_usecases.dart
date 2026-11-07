import 'dart:typed_data';

import '../entities/ai_entities.dart';
import '../repositories/ai_assistant_repository.dart';

class RecognizeLandmarkUseCase {
  const RecognizeLandmarkUseCase(this._repository);
  final AiAssistantRepository _repository;

  Future<LandmarkRecognition> call(Uint8List imageBytes) => _repository.recognizeLandmark(imageBytes);
}

class GenerateItineraryUseCase {
  const GenerateItineraryUseCase(this._repository);
  final AiAssistantRepository _repository;

  Future<GeneratedItinerary> call(ItineraryRequest request) {
    if (request.interests.isEmpty) {
      throw ArgumentError('Vui lòng chọn ít nhất một sở thích.');
    }
    return _repository.generateItinerary(request);
  }
}

class SendChatMessageUseCase {
  const SendChatMessageUseCase(this._repository);
  final AiAssistantRepository _repository;

  Future<ChatMessage> call(List<ChatMessage> history, String message) =>
      _repository.sendChatMessage(history, message.trim());
}
