import '../entities/destination_discovery_entity.dart';
import '../repositories/destination_discovery_repository.dart';

/// [FE-02] Primary UseCase for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
class GetDestinationDiscoveryUseCase {
  final DestinationDiscoveryRepository repository;

  GetDestinationDiscoveryUseCase(this.repository);

  Future<List<DestinationEntity>> execute() async {
    return await repository.getItems();
  }
}
