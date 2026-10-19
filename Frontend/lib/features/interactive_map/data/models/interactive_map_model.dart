import '../../domain/entities/interactive_map_entity.dart';

/// [FE-04] Data Model with Firestore serialization for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
class PoiLocationModel extends PoiLocationEntity {
  const PoiLocationModel({
    required super.id,
    required super.title,
  });

  factory PoiLocationModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return PoiLocationModel(
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
