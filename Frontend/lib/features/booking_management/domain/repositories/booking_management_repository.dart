import 'booking_management_entity.dart';

/// [FE-07] Domain Repository Interface for Booking Management (Create/Confirm/Cancel Booking, Booking History)
abstract class BookingManagementRepository {
  Future<List<BookingEntity>> getItems();
  Future<BookingEntity> getItemById(String id);
}
