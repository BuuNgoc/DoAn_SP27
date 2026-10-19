import 'vr360_audio_guide_entity.dart';

/// [FE-03] Domain Repository Interface for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
abstract class Vr360AudioGuideRepository {
  Future<List<Vr360AudioEntity>> getItems();
  Future<Vr360AudioEntity> getItemById(String id);
}
