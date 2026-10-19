import 'package:equatable/equatable.dart';

/// [FE-05 & RAG] Entity for AI Photo Recognition & RAG Itinerary Planner (Gemini Vision & Vector Embeddings)
class AiAssistantEntity extends Equatable {
  final String id;
  final String title;

  const AiAssistantEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
