import 'package:equatable/equatable.dart';

/// [FE-08, FE-09] Entity for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
class CheckinLoyaltyEntity extends Equatable {
  final String id;
  final String title;

  const CheckinLoyaltyEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
