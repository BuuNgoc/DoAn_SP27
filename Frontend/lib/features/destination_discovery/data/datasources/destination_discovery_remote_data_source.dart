import '../models/destination_discovery_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-02] Remote DataSource for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
abstract class DestinationDiscoveryRemoteDataSource {
  Future<List<DestinationModel>> fetchItems();
  Future<DestinationModel> fetchItemById(String id);
}

class DestinationDiscoveryRemoteDataSourceImpl implements DestinationDiscoveryRemoteDataSource {
  final FirestoreService firestoreService;

  DestinationDiscoveryRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<DestinationModel>> fetchItems() async {
    // Stub implementation for FE-02
    return [];
  }

  @override
  Future<DestinationModel> fetchItemById(String id) async {
    // Stub implementation for FE-02
    return DestinationModel(id: id, title: 'Item $id');
  }
}
