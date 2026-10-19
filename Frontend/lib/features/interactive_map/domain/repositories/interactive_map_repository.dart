import 'interactive_map_entity.dart';

/// [FE-04] Domain Repository Interface for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
abstract class InteractiveMapRepository {
  Future<List<PoiLocationEntity>> getItems();
  Future<PoiLocationEntity> getItemById(String id);
}
