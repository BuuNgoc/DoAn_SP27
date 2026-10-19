import '../entities/events_workshops_craft_entity.dart';
import '../repositories/events_workshops_craft_repository.dart';

/// [FE-06, FE-15, FE-16] Primary UseCase for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class GetEventsWorkshopsCraftUseCase {
  final EventsWorkshopsCraftRepository repository;

  GetEventsWorkshopsCraftUseCase(this.repository);

  Future<List<EventCraftEntity>> execute() async {
    return await repository.getItems();
  }
}
