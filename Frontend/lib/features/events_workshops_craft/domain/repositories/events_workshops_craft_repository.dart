import 'events_workshops_craft_entity.dart';

/// [FE-06, FE-15, FE-16] Domain Repository Interface for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
abstract class EventsWorkshopsCraftRepository {
  Future<List<EventCraftEntity>> getItems();
  Future<EventCraftEntity> getItemById(String id);
}
