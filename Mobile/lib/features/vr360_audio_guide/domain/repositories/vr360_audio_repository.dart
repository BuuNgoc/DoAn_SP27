import '../entities/vr360_audio_entities.dart';

/// [FE-03] Hợp đồng tầng domain cho VR360 & Audio Guide.
abstract class Vr360AudioRepository {
  /// Danh sách góc nhìn 360° của điểm đến (rỗng nếu chưa có nội dung VR).
  Future<List<Vr360Scene>> getScenes(String destinationId);

  /// Bài thuyết minh của điểm đến, `null` nếu chưa có.
  Future<AudioGuide?> getAudioGuide(String destinationId);
}
