import '../entities/booking_management_entity.dart';
import '../repositories/booking_management_repository.dart';

/// [FE-07] Primary UseCase for Booking Management (Create/Confirm/Cancel Booking, Booking History)
class GetBookingManagementUseCase {
  final BookingManagementRepository repository;

  GetBookingManagementUseCase(this.repository);

  Future<List<BookingEntity>> execute() async {
    return await repository.getItems();
  }
}
