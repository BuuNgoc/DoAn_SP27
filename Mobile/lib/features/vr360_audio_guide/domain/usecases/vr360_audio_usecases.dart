import '../entities/vr360_audio_entities.dart';
import '../repositories/vr360_audio_repository.dart';

/// [FE-03] View VR360 content by location.
class GetVr360ScenesUseCase {
  const GetVr360ScenesUseCase(this._repository);
  final Vr360AudioRepository _repository;
  Future<List<Vr360Scene>> call(String destinationId) => _repository.getScenes(destinationId);
}

/// [FE-03] Play audio guide / view audio guide information.
class GetAudioGuideUseCase {
  const GetAudioGuideUseCase(this._repository);
  final Vr360AudioRepository _repository;
  Future<AudioGuide?> call(String destinationId) => _repository.getAudioGuide(destinationId);
}
