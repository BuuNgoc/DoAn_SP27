import '../entities/loyalty_entities.dart';

/// [FE-08, FE-09] Hợp đồng dữ liệu check-in & điểm thưởng.
abstract class LoyaltyRepository {
  Future<List<CheckinPoint>> getCheckinPoints();
  Future<List<CheckinRecord>> getCheckinHistory(String userId);
  Future<CheckinResult> checkIn(String userId, String qrPayload);

  Future<LoyaltySummary> getSummary(String userId);
  Future<List<Reward>> getRewards();
  Future<Redemption> redeem(String userId, String rewardId);
  Future<List<Redemption>> getRedemptions(String userId);
}
