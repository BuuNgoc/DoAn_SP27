import '../models/vr360_audio_guide_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-03] Remote DataSource for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
abstract class Vr360AudioGuideRemoteDataSource {
  Future<List<Vr360AudioModel>> fetchItems();
  Future<Vr360AudioModel> fetchItemById(String id);
}

class Vr360AudioGuideRemoteDataSourceImpl implements Vr360AudioGuideRemoteDataSource {
  final FirestoreService firestoreService;

  Vr360AudioGuideRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<Vr360AudioModel>> fetchItems() async {
    // Stub implementation for FE-03
    return [];
  }

  @override
  Future<Vr360AudioModel> fetchItemById(String id) async {
    // Stub implementation for FE-03
    return Vr360AudioModel(id: id, title: 'Item $id');
  }
}
