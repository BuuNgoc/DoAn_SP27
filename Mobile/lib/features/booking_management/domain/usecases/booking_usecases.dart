import '../entities/booking_entities.dart';
import '../repositories/booking_repository.dart';

class GetBookableServicesUseCase {
  const GetBookableServicesUseCase(this._r);
  final BookingRepository _r;
  Future<List<BookableService>> call() => _r.getBookableServices();
}

class CreateBookingUseCase {
  const CreateBookingUseCase(this._r);
  final BookingRepository _r;

  Future<Booking> call(BookingRequest request) {
    if (request.participants < 1) throw ArgumentError('Số người tham gia phải từ 1 trở lên.');
    if (request.participants > request.service.remainingSlots) {
      throw ArgumentError('Chỉ còn ${request.service.remainingSlots} chỗ trống.');
    }
    if (request.participants > request.service.maxPerBooking) {
      throw ArgumentError('Mỗi lượt đặt tối đa ${request.service.maxPerBooking} người.');
    }
    return _r.createBooking(request);
  }
}

class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this._r);
  final BookingRepository _r;
  Future<List<Booking>> call(String userId) => _r.getMyBookings(userId);
}

class GetBookingDetailUseCase {
  const GetBookingDetailUseCase(this._r);
  final BookingRepository _r;
  Future<Booking> call(String id) => _r.getBooking(id);
}

class CancelBookingUseCase {
  const CancelBookingUseCase(this._r);
  final BookingRepository _r;
  Future<Booking> call(String id) => _r.cancelBooking(id);
}
