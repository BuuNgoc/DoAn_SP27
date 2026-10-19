import '../../domain/entities/specialized_zones_entity.dart';

/// [FE-12, FE-13, FE-14] Data Model with Firestore serialization for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
class ZoneModel extends ZoneEntity {
  const ZoneModel({
    required super.id,
    required super.title,
  });

  factory ZoneModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ZoneModel(
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
