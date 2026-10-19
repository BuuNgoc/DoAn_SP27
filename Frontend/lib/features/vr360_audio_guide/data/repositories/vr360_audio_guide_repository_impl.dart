import '../../domain/entities/vr360_audio_guide_entity.dart';
import '../../domain/repositories/vr360_audio_guide_repository.dart';
import '../datasources/vr360_audio_guide_remote_data_source.dart';

/// [FE-03] Repository Implementation for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
class Vr360AudioGuideRepositoryImpl implements Vr360AudioGuideRepository {
  final Vr360AudioGuideRemoteDataSource remoteDataSource;

  Vr360AudioGuideRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Vr360AudioEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<Vr360AudioEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
