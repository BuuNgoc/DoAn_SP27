import '../../domain/entities/qr_checkin_loyalty_entity.dart';

/// [FE-08, FE-09] Data Model with Firestore serialization for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
class CheckinLoyaltyModel extends CheckinLoyaltyEntity {
  const CheckinLoyaltyModel({
    required super.id,
    required super.title,
  });

  factory CheckinLoyaltyModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return CheckinLoyaltyModel(
      id: documentId,
      title: data['title'] as String? ?? data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
    };
  }
}
