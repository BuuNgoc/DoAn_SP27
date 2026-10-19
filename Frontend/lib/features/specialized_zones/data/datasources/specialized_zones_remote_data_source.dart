import '../models/specialized_zones_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-12, FE-13, FE-14] Remote DataSource for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
abstract class SpecializedZonesRemoteDataSource {
  Future<List<ZoneModel>> fetchItems();
  Future<ZoneModel> fetchItemById(String id);
}

class SpecializedZonesRemoteDataSourceImpl implements SpecializedZonesRemoteDataSource {
  final FirestoreService firestoreService;

  SpecializedZonesRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<ZoneModel>> fetchItems() async {
    // Stub implementation for FE-12, FE-13, FE-14
    return [];
  }

  @override
  Future<ZoneModel> fetchItemById(String id) async {
    // Stub implementation for FE-12, FE-13, FE-14
    return ZoneModel(id: id, title: 'Item $id');
  }
}
