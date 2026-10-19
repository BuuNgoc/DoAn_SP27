import '../entities/specialized_zones_entity.dart';
import '../repositories/specialized_zones_repository.dart';

/// [FE-12, FE-13, FE-14] Primary UseCase for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
class GetSpecializedZonesUseCase {
  final SpecializedZonesRepository repository;

  GetSpecializedZonesUseCase(this.repository);

  Future<List<ZoneEntity>> execute() async {
    return await repository.getItems();
  }
}
