import '../../domain/entities/vr360_audio_entities.dart';

/// [FE-03] Model Firestore `destinations/{id}/vr360_contents/{vrId}`.
class Vr360SceneModel extends Vr360Scene {
  const Vr360SceneModel({
    required super.id,
    required super.destinationId,
    required super.title,
    required super.subtitle,
    required super.panoramaImage,
    super.initialLongitude,
    super.hotspots,
  });

  factory Vr360SceneModel.fromFirestore(Map<String, dynamic> data, String id, String destinationId) {
    final hotspots = (data['hotspots'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((h) => Vr360Hotspot(
              id: h['id'] as String? ?? '',
              label: h['label'] as String? ?? '',
              description: h['description'] as String? ?? '',
              latitude: (h['latitude'] as num?)?.toDouble() ?? 0,
              longitude: (h['longitude'] as num?)?.toDouble() ?? 0,
              targetSceneId: h['targetSceneId'] as String?,
            ))
        .toList();
    return Vr360SceneModel(
      id: id,
      destinationId: destinationId,
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? '',
      panoramaImage: data['panoramaUrl'] as String? ?? '',
      initialLongitude: (data['initialLongitude'] as num?)?.toDouble() ?? 0,
      hotspots: hotspots,
    );
  }
}

/// [FE-03] Model Firestore `destinations/{id}/audio_guides/{audioId}`.
class AudioGuideModel extends AudioGuide {
  const AudioGuideModel({
    required super.id,
    required super.destinationId,
    required super.title,
    required super.durationSeconds,
    required super.transcripts,
    super.audioUrls,
    super.narrator,
  });

  factory AudioGuideModel.fromFirestore(Map<String, dynamic> data, String id, String destinationId) {
    return AudioGuideModel(
      id: id,
      destinationId: destinationId,
      title: data['title'] as String? ?? '',
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      transcripts: Map<String, String>.from(data['transcripts'] as Map? ?? const {}),
      audioUrls: Map<String, String>.from(data['audioUrls'] as Map? ?? const {}),
      narrator: data['narrator'] as String? ?? 'Thuyết minh viên SmartTravel',
    );
  }
}
