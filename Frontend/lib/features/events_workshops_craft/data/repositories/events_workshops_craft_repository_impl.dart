import '../../domain/entities/events_workshops_craft_entity.dart';
import '../../domain/repositories/events_workshops_craft_repository.dart';
import '../datasources/events_workshops_craft_remote_data_source.dart';

/// [FE-06, FE-15, FE-16] Repository Implementation for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class EventsWorkshopsCraftRepositoryImpl implements EventsWorkshopsCraftRepository {
  final EventsWorkshopsCraftRemoteDataSource remoteDataSource;

  EventsWorkshopsCraftRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<EventCraftEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<EventCraftEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
