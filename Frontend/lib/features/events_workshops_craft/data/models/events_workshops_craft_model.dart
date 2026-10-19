import '../../domain/entities/events_workshops_craft_entity.dart';

/// [FE-06, FE-15, FE-16] Data Model with Firestore serialization for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class EventCraftModel extends EventCraftEntity {
  const EventCraftModel({
    required super.id,
    required super.title,
  });

  factory EventCraftModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return EventCraftModel(
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
