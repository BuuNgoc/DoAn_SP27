import 'destination_discovery_entity.dart';

/// [FE-02] Domain Repository Interface for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
abstract class DestinationDiscoveryRepository {
  Future<List<DestinationEntity>> getItems();
  Future<DestinationEntity> getItemById(String id);
}
