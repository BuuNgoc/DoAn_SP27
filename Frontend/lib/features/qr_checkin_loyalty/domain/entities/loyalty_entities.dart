import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// [FE-08] Điểm check-in QR tại điểm đến.
class CheckinPoint extends Equatable {
  const CheckinPoint({
    required this.id,
    required this.name,
    required this.area,
    required this.description,
    required this.points,
    required this.image,
    this.destinationId,
  });

  final String id;
  final String name;
  final String area;
  final String description;
  final int points;
  final String image;
  final String? destinationId;

  /// Nội dung mã QR in tại điểm đến.
  String get qrPayload => 'SMARTTRAVEL|CHECKIN|$id';

  @override
  List<Object?> get props => [id];
}

class CheckinRecord extends Equatable {
  const CheckinRecord({
    required this.id,
    required this.pointId,
    required this.pointName,
    required this.pointsEarned,
    required this.checkedInAt,
  });

  final String id;
  final String pointId;
  final String pointName;
  final int pointsEarned;
  final DateTime checkedInAt;

  @override
  List<Object?> get props => [id];
}

/// Hạng thành viên theo tổng điểm tích lũy trọn đời.
enum MemberTier {
  traveler('Lữ khách', 0, Icons.hiking_rounded, Color(0xFF94AEB2)),
  explorer('Nhà thám hiểm', 500, Icons.explore_rounded, Color(0xFF58B4BC)),
  ambassador('Sứ giả Ngũ Hành', 1500, Icons.workspace_premium_rounded, Color(0xFF24838B)),
  legend('Huyền thoại Non Nước', 3000, Icons.diamond_rounded, Color(0xFFE4B363));

  const MemberTier(this.label, this.minPoints, this.icon, this.color);
  final String label;
  final int minPoints;
  final IconData icon;
  final Color color;

  static MemberTier of(int lifetimePoints) =>
      values.lastWhere((t) => lifetimePoints >= t.minPoints, orElse: () => MemberTier.traveler);

  MemberTier? get next => index + 1 < values.length ? values[index + 1] : null;
}

/// [FE-09] Tổng quan điểm thưởng.
class LoyaltySummary extends Equatable {
  const LoyaltySummary({required this.availablePoints, required this.lifetimePoints});

  final int availablePoints;
  final int lifetimePoints;

  MemberTier get tier => MemberTier.of(lifetimePoints);

  /// Tiến độ lên hạng kế tiếp (0..1).
  double get tierProgress {
    final next = tier.next;
    if (next == null) return 1;
    return ((lifetimePoints - tier.minPoints) / (next.minPoints - tier.minPoints)).clamp(0, 1);
  }

  int get pointsToNextTier => tier.next == null ? 0 : tier.next!.minPoints - lifetimePoints;

  @override
  List<Object?> get props => [availablePoints, lifetimePoints];
}

enum RewardCategory {
  souvenir('Quà lưu niệm đá', Icons.redeem_rounded),
  voucher('Voucher', Icons.confirmation_number_rounded);

  const RewardCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// [FE-09] Phần thưởng đổi điểm.
class Reward extends Equatable {
  const Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.image,
    required this.category,
    required this.stock,
    required this.partner,
    required this.pickupLocation,
    this.terms = const [],
  });

  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String image;
  final RewardCategory category;
  final int stock;
  final String partner;
  final String pickupLocation;
  final List<String> terms;

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [id, stock];
}

enum RedemptionStatus {
  ready('Chờ nhận quà', Color(0xFF4CAF7A)),
  used('Đã sử dụng', Color(0xFF94AEB2)),
  expired('Hết hạn', Color(0xFFE56B6B));

  const RedemptionStatus(this.label, this.color);
  final String label;
  final Color color;
}

class Redemption extends Equatable {
  const Redemption({
    required this.id,
    required this.rewardId,
    required this.rewardTitle,
    required this.rewardImage,
    required this.pointsSpent,
    required this.code,
    required this.redeemedAt,
    required this.expiresAt,
    required this.status,
    required this.pickupLocation,
  });

  final String id;
  final String rewardId;
  final String rewardTitle;
  final String rewardImage;
  final int pointsSpent;
  final String code;
  final DateTime redeemedAt;
  final DateTime expiresAt;
  final RedemptionStatus status;
  final String pickupLocation;

  @override
  List<Object?> get props => [id, status];
}

/// Kết quả một lần check-in thành công.
class CheckinResult extends Equatable {
  const CheckinResult({
    required this.point,
    required this.record,
    required this.summary,
    required this.previousTier,
    required this.collectedCount,
    required this.totalPoints,
  });

  final CheckinPoint point;
  final CheckinRecord record;
  final LoyaltySummary summary;
  final MemberTier previousTier;
  final int collectedCount;
  final int totalPoints;

  bool get tierUpgraded => summary.tier.index > previousTier.index;

  @override
  List<Object?> get props => [record];
}
