import '../models/booking_management_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-07] Remote DataSource for Booking Management (Create/Confirm/Cancel Booking, Booking History)
abstract class BookingManagementRemoteDataSource {
  Future<List<BookingModel>> fetchItems();
  Future<BookingModel> fetchItemById(String id);
}

class BookingManagementRemoteDataSourceImpl implements BookingManagementRemoteDataSource {
  final FirestoreService firestoreService;

  BookingManagementRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<BookingModel>> fetchItems() async {
    // Stub implementation for FE-07
    return [];
  }

  @override
  Future<BookingModel> fetchItemById(String id) async {
    // Stub implementation for FE-07
    return BookingModel(id: id, title: 'Item $id');
  }
}
