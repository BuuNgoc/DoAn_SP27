import 'specialized_zones_entity.dart';

/// [FE-12, FE-13, FE-14] Domain Repository Interface for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
abstract class SpecializedZonesRepository {
  Future<List<ZoneEntity>> getItems();
  Future<ZoneEntity> getItemById(String id);
}
