import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

/// [FE-02] View list / Search / Filter by category.
class GetDestinationsUseCase {
  const GetDestinationsUseCase(this._repository);
  final DestinationRepository _repository;
  Future<List<Destination>> call({DestinationCategory? category, String? query}) =>
      _repository.getDestinations(category: category, query: query);
}

/// [FE-02] View destination details.
class GetDestinationDetailUseCase {
  const GetDestinationDetailUseCase(this._repository);
  final DestinationRepository _repository;
  Future<Destination> call(String id) => _repository.getDestinationById(id);
}

/// [FE-02] Save favorite destination (offline-first).
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);
  final DestinationRepository _repository;
  Future<bool> call(String id) => _repository.toggleFavorite(id);
}

class GetFavoriteIdsUseCase {
  const GetFavoriteIdsUseCase(this._repository);
  final DestinationRepository _repository;
  Future<Set<String>> call() => _repository.getFavoriteIds();
}

/// [FE-02] Recently viewed destinations (offline-first via Hive).
class GetRecentlyViewedIdsUseCase {
  const GetRecentlyViewedIdsUseCase(this._repository);
  final DestinationRepository _repository;
  Future<List<String>> call() => _repository.getRecentlyViewedIds();
}

class AddRecentlyViewedUseCase {
  const AddRecentlyViewedUseCase(this._repository);
  final DestinationRepository _repository;
  Future<List<String>> call(String id) => _repository.addRecentlyViewed(id);
}

class ClearRecentlyViewedUseCase {
  const ClearRecentlyViewedUseCase(this._repository);
  final DestinationRepository _repository;
  Future<void> call() => _repository.clearRecentlyViewed();
}
