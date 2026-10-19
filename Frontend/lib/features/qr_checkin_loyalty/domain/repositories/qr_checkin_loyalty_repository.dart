import 'qr_checkin_loyalty_entity.dart';

/// [FE-08, FE-09] Domain Repository Interface for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
abstract class QrCheckinLoyaltyRepository {
  Future<List<CheckinLoyaltyEntity>> getItems();
  Future<CheckinLoyaltyEntity> getItemById(String id);
}
