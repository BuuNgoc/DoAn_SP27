import '../entities/map_poi.dart';
import '../repositories/map_repository.dart';

class GetMapPoisUseCase {
  const GetMapPoisUseCase(this._repository);
  final MapRepository _repository;

  Future<List<MapPoi>> call() => _repository.getPois();
}
