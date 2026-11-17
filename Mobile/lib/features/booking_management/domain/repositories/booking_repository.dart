import '../entities/booking_entities.dart';

/// [FE-07] Hợp đồng dữ liệu đặt chỗ.
abstract class BookingRepository {
  Future<List<BookableService>> getBookableServices();
  Future<BookableService> getService(String serviceId);
  Future<Booking> createBooking(BookingRequest request);
  Future<List<Booking>> getMyBookings(String userId);
  Future<Booking> getBooking(String bookingId);
  Future<Booking> cancelBooking(String bookingId);
}
