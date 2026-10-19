import '../../domain/entities/qr_checkin_loyalty_entity.dart';
import '../../domain/repositories/qr_checkin_loyalty_repository.dart';
import '../datasources/qr_checkin_loyalty_remote_data_source.dart';

/// [FE-08, FE-09] Repository Implementation for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
class QrCheckinLoyaltyRepositoryImpl implements QrCheckinLoyaltyRepository {
  final QrCheckinLoyaltyRemoteDataSource remoteDataSource;

  QrCheckinLoyaltyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CheckinLoyaltyEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<CheckinLoyaltyEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
