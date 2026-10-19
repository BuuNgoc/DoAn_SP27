import '../../domain/entities/destination_discovery_entity.dart';

/// [FE-02] Data Model with Firestore serialization for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
class DestinationModel extends DestinationEntity {
  const DestinationModel({
    required super.id,
    required super.title,
  });

  factory DestinationModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return DestinationModel(
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
