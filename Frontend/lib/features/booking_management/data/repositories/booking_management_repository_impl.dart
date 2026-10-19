import '../../domain/entities/booking_management_entity.dart';
import '../../domain/repositories/booking_management_repository.dart';
import '../datasources/booking_management_remote_data_source.dart';

/// [FE-07] Repository Implementation for Booking Management (Create/Confirm/Cancel Booking, Booking History)
class BookingManagementRepositoryImpl implements BookingManagementRepository {
  final BookingManagementRemoteDataSource remoteDataSource;

  BookingManagementRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BookingEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<BookingEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
