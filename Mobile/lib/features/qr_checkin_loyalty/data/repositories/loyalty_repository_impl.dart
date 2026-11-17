import '../../domain/entities/loyalty_entities.dart';
import '../../domain/repositories/loyalty_repository.dart';
import '../datasources/loyalty_remote_data_source.dart';

class LoyaltyRepositoryImpl implements LoyaltyRepository {
  LoyaltyRepositoryImpl(this._remote);

  final LoyaltyRemoteDataSource _remote;

  @override
  Future<List<CheckinPoint>> getCheckinPoints() => _remote.fetchPoints();

  @override
  Future<List<CheckinRecord>> getCheckinHistory(String userId) => _remote.fetchHistory(userId);

  @override
  Future<CheckinResult> checkIn(String userId, String qrPayload) async {
    final pointId = qrPayload.split('|').last.trim();
    final before = await _remote.fetchSummary(userId);
    final points = await _remote.fetchPoints();
    final record = await _remote.checkIn(userId, pointId);
    final after = await _remote.fetchSummary(userId);
    final history = await _remote.fetchHistory(userId);
    final point = points.firstWhere((p) => p.id == record.pointId);
    return CheckinResult(
      point: point,
      record: record,
      summary: after,
      previousTier: before.tier,
      collectedCount: history.map((h) => h.pointId).toSet().length,
      totalPoints: points.length,
    );
  }

  @override
  Future<LoyaltySummary> getSummary(String userId) => _remote.fetchSummary(userId);

  @override
  Future<List<Reward>> getRewards() async {
    final list = await _remote.fetchRewards();
    return list..sort((a, b) => a.pointsCost.compareTo(b.pointsCost));
  }

  @override
  Future<Redemption> redeem(String userId, String rewardId) => _remote.redeem(userId, rewardId);

  @override
  Future<List<Redemption>> getRedemptions(String userId) => _remote.fetchRedemptions(userId);
}
