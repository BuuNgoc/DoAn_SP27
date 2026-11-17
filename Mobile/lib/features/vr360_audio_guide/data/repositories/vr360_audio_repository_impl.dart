import '../../domain/entities/vr360_audio_entities.dart';
import '../../domain/repositories/vr360_audio_repository.dart';
import '../datasources/vr360_audio_data_source.dart';

class Vr360AudioRepositoryImpl implements Vr360AudioRepository {
  const Vr360AudioRepositoryImpl(this._remote);

  final Vr360AudioRemoteDataSource _remote;

  @override
  Future<List<Vr360Scene>> getScenes(String destinationId) => _remote.fetchScenes(destinationId);

  @override
  Future<AudioGuide?> getAudioGuide(String destinationId) => _remote.fetchAudioGuide(destinationId);
}
