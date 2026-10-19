import '../models/events_workshops_craft_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-06, FE-15, FE-16] Remote DataSource for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
abstract class EventsWorkshopsCraftRemoteDataSource {
  Future<List<EventCraftModel>> fetchItems();
  Future<EventCraftModel> fetchItemById(String id);
}

class EventsWorkshopsCraftRemoteDataSourceImpl implements EventsWorkshopsCraftRemoteDataSource {
  final FirestoreService firestoreService;

  EventsWorkshopsCraftRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<EventCraftModel>> fetchItems() async {
    // Stub implementation for FE-06, FE-15, FE-16
    return [];
  }

  @override
  Future<EventCraftModel> fetchItemById(String id) async {
    // Stub implementation for FE-06, FE-15, FE-16
    return EventCraftModel(id: id, title: 'Item $id');
  }
}
