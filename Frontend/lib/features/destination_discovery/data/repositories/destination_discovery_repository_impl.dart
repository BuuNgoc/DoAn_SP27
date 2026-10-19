import '../../domain/entities/destination_discovery_entity.dart';
import '../../domain/repositories/destination_discovery_repository.dart';
import '../datasources/destination_discovery_remote_data_source.dart';

/// [FE-02] Repository Implementation for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
class DestinationDiscoveryRepositoryImpl implements DestinationDiscoveryRepository {
  final DestinationDiscoveryRemoteDataSource remoteDataSource;

  DestinationDiscoveryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<DestinationEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<DestinationEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
