import '../entities/qr_checkin_loyalty_entity.dart';
import '../repositories/qr_checkin_loyalty_repository.dart';

/// [FE-08, FE-09] Primary UseCase for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
class GetQrCheckinLoyaltyUseCase {
  final QrCheckinLoyaltyRepository repository;

  GetQrCheckinLoyaltyUseCase(this.repository);

  Future<List<CheckinLoyaltyEntity>> execute() async {
    return await repository.getItems();
  }
}
