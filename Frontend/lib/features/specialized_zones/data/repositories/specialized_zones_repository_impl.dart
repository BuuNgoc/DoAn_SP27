import '../../domain/entities/specialized_zones_entity.dart';
import '../../domain/repositories/specialized_zones_repository.dart';
import '../datasources/specialized_zones_remote_data_source.dart';

/// [FE-12, FE-13, FE-14] Repository Implementation for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
class SpecializedZonesRepositoryImpl implements SpecializedZonesRepository {
  final SpecializedZonesRemoteDataSource remoteDataSource;

  SpecializedZonesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ZoneEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<ZoneEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
