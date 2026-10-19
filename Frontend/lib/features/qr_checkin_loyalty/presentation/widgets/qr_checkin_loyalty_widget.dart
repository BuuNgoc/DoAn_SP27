import 'package:flutter/material.dart';
import '../../domain/entities/qr_checkin_loyalty_entity.dart';

/// [FE-08, FE-09] Card Widget for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
class QrCheckinLoyaltyCardWidget extends StatelessWidget {
  final CheckinLoyaltyEntity item;
  final VoidCallback? onTap;

  const QrCheckinLoyaltyCardWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
