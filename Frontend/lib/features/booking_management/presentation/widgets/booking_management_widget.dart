import 'package:flutter/material.dart';
import '../../domain/entities/booking_management_entity.dart';

/// [FE-07] Card Widget for Booking Management (Create/Confirm/Cancel Booking, Booking History)
class BookingManagementCardWidget extends StatelessWidget {
  final BookingEntity item;
  final VoidCallback? onTap;

  const BookingManagementCardWidget({
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
