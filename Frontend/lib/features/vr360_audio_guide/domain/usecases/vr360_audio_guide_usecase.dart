import '../entities/vr360_audio_guide_entity.dart';
import '../repositories/vr360_audio_guide_repository.dart';

/// [FE-03] Primary UseCase for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
class GetVr360AudioGuideUseCase {
  final Vr360AudioGuideRepository repository;

  GetVr360AudioGuideUseCase(this.repository);

  Future<List<Vr360AudioEntity>> execute() async {
    return await repository.getItems();
  }
}
