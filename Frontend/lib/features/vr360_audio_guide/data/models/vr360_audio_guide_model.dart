import '../../domain/entities/vr360_audio_guide_entity.dart';

/// [FE-03] Data Model with Firestore serialization for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
class Vr360AudioModel extends Vr360AudioEntity {
  const Vr360AudioModel({
    required super.id,
    required super.title,
  });

  factory Vr360AudioModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Vr360AudioModel(
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
