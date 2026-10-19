import '../models/interactive_map_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-04] Remote DataSource for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
abstract class InteractiveMapRemoteDataSource {
  Future<List<PoiLocationModel>> fetchItems();
  Future<PoiLocationModel> fetchItemById(String id);
}

class InteractiveMapRemoteDataSourceImpl implements InteractiveMapRemoteDataSource {
  final FirestoreService firestoreService;

  InteractiveMapRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<PoiLocationModel>> fetchItems() async {
    // Stub implementation for FE-04
    return [];
  }

  @override
  Future<PoiLocationModel> fetchItemById(String id) async {
    // Stub implementation for FE-04
    return PoiLocationModel(id: id, title: 'Item $id');
  }
}
