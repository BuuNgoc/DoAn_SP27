import '../entities/loyalty_entities.dart';
import '../repositories/loyalty_repository.dart';

class GetCheckinPointsUseCase {
  const GetCheckinPointsUseCase(this._r);
  final LoyaltyRepository _r;
  Future<List<CheckinPoint>> call() => _r.getCheckinPoints();
}

class GetCheckinHistoryUseCase {
  const GetCheckinHistoryUseCase(this._r);
  final LoyaltyRepository _r;
  Future<List<CheckinRecord>> call(String userId) => _r.getCheckinHistory(userId);
}

class CheckInUseCase {
  const CheckInUseCase(this._r);
  final LoyaltyRepository _r;

  Future<CheckinResult> call(String userId, String qrPayload) {
    if (!qrPayload.startsWith('SMARTTRAVEL|CHECKIN|')) {
      throw ArgumentError('Mã QR không thuộc hệ thống check-in SmartTravel.');
    }
    return _r.checkIn(userId, qrPayload);
  }
}

class GetLoyaltySummaryUseCase {
  const GetLoyaltySummaryUseCase(this._r);
  final LoyaltyRepository _r;
  Future<LoyaltySummary> call(String userId) => _r.getSummary(userId);
}

class GetRewardsUseCase {
  const GetRewardsUseCase(this._r);
  final LoyaltyRepository _r;
  Future<List<Reward>> call() => _r.getRewards();
}

class RedeemRewardUseCase {
  const RedeemRewardUseCase(this._r);
  final LoyaltyRepository _r;
  Future<Redemption> call(String userId, String rewardId) => _r.redeem(userId, rewardId);
}

class GetRedemptionsUseCase {
  const GetRedemptionsUseCase(this._r);
  final LoyaltyRepository _r;
  Future<List<Redemption>> call(String userId) => _r.getRedemptions(userId);
}
