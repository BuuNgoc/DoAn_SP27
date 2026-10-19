import '../../domain/entities/interactive_map_entity.dart';
import '../../domain/repositories/interactive_map_repository.dart';
import '../datasources/interactive_map_remote_data_source.dart';

/// [FE-04] Repository Implementation for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
class InteractiveMapRepositoryImpl implements InteractiveMapRepository {
  final InteractiveMapRemoteDataSource remoteDataSource;

  InteractiveMapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<PoiLocationEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<PoiLocationEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
