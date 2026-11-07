import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/loyalty_entities.dart';
import '../../domain/usecases/loyalty_usecases.dart';

class LoyaltyState extends Equatable {
  const LoyaltyState({
    this.status = ViewStatus.initial,
    this.userId,
    this.summary = const LoyaltySummary(availablePoints: 0, lifetimePoints: 0),
    this.points = const [],
    this.history = const [],
    this.rewards = const [],
    this.redemptions = const [],
    this.busy = false,
    this.errorMessage,
  });

  final ViewStatus status;
  final String? userId;
  final LoyaltySummary summary;
  final List<CheckinPoint> points;
  final List<CheckinRecord> history;
  final List<Reward> rewards;
  final List<Redemption> redemptions;

  /// Đang check-in hoặc đổi quà.
  final bool busy;
  final String? errorMessage;

  Set<String> get collectedPointIds => history.map((h) => h.pointId).toSet();
  double get collectionProgress => points.isEmpty ? 0 : collectedPointIds.length / points.length;

  LoyaltyState copyWith({
    ViewStatus? status,
    String? userId,
    LoyaltySummary? summary,
    List<CheckinPoint>? points,
    List<CheckinRecord>? history,
    List<Reward>? rewards,
    List<Redemption>? redemptions,
    bool? busy,
    String? errorMessage,
  }) =>
      LoyaltyState(
        status: status ?? this.status,
        userId: userId ?? this.userId,
        summary: summary ?? this.summary,
        points: points ?? this.points,
        history: history ?? this.history,
        rewards: rewards ?? this.rewards,
        redemptions: redemptions ?? this.redemptions,
        busy: busy ?? this.busy,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, userId, summary, points, history, rewards, redemptions, busy, errorMessage];
}

/// [FE-08, FE-09] Cubit toàn cục cho check-in & điểm thưởng (dùng ở tab Check-in, Cá nhân).
class LoyaltyCubit extends Cubit<LoyaltyState> {
  LoyaltyCubit({
    required GetCheckinPointsUseCase getPoints,
    required GetCheckinHistoryUseCase getHistory,
    required CheckInUseCase checkIn,
    required GetLoyaltySummaryUseCase getSummary,
    required GetRewardsUseCase getRewards,
    required RedeemRewardUseCase redeem,
    required GetRedemptionsUseCase getRedemptions,
  })  : _getPoints = getPoints,
        _getHistory = getHistory,
        _checkIn = checkIn,
        _getSummary = getSummary,
        _getRewards = getRewards,
        _redeem = redeem,
        _getRedemptions = getRedemptions,
        super(const LoyaltyState());

  final GetCheckinPointsUseCase _getPoints;
  final GetCheckinHistoryUseCase _getHistory;
  final CheckInUseCase _checkIn;
  final GetLoyaltySummaryUseCase _getSummary;
  final GetRewardsUseCase _getRewards;
  final RedeemRewardUseCase _redeem;
  final GetRedemptionsUseCase _getRedemptions;

  /// Tải dữ liệu; khách (userId null) vẫn xem được điểm check-in và danh sách quà.
  Future<void> load(String? userId) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final points = await _getPoints();
      final rewards = await _getRewards();
      if (userId == null) {
        emit(LoyaltyState(status: ViewStatus.success, points: points, rewards: rewards));
        return;
      }
      final results = await Future.wait([_getSummary(userId), _getHistory(userId), _getRedemptions(userId)]);
      emit(LoyaltyState(
        status: ViewStatus.success,
        userId: userId,
        points: points,
        rewards: rewards,
        summary: results[0] as LoyaltySummary,
        history: results[1] as List<CheckinRecord>,
        redemptions: results[2] as List<Redemption>,
      ));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void clear() => emit(const LoyaltyState());

  Future<({CheckinResult? result, String? error})> checkIn(String qrPayload) async {
    final userId = state.userId;
    if (userId == null) return (result: null, error: 'Vui lòng đăng nhập để check-in.');
    emit(state.copyWith(busy: true));
    try {
      final result = await _checkIn(userId, qrPayload);
      final history = await _getHistory(userId);
      emit(state.copyWith(busy: false, summary: result.summary, history: history));
      return (result: result, error: null);
    } catch (e) {
      emit(state.copyWith(busy: false));
      return (result: null, error: errorMessageOf(e));
    }
  }

  Future<({Redemption? redemption, String? error})> redeem(String rewardId) async {
    final userId = state.userId;
    if (userId == null) return (redemption: null, error: 'Vui lòng đăng nhập để đổi quà.');
    emit(state.copyWith(busy: true));
    try {
      final redemption = await _redeem(userId, rewardId);
      final results = await Future.wait([_getSummary(userId), _getRewards(), _getRedemptions(userId)]);
      emit(state.copyWith(
        busy: false,
        summary: results[0] as LoyaltySummary,
        rewards: results[1] as List<Reward>,
        redemptions: results[2] as List<Redemption>,
      ));
      return (redemption: redemption, error: null);
    } catch (e) {
      emit(state.copyWith(busy: false));
      return (redemption: null, error: errorMessageOf(e));
    }
  }
}
