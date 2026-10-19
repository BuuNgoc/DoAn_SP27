import '../entities/interactive_map_entity.dart';
import '../repositories/interactive_map_repository.dart';

/// [FE-04] Primary UseCase for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
class GetInteractiveMapUseCase {
  final InteractiveMapRepository repository;

  GetInteractiveMapUseCase(this.repository);

  Future<List<PoiLocationEntity>> execute() async {
    return await repository.getItems();
  }
}
