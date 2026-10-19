import 'package:flutter/material.dart';
import '../../domain/entities/reviews_social_sharing_entity.dart';

/// [FE-10, FE-11] Card Widget for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
class ReviewsSocialSharingCardWidget extends StatelessWidget {
  final ReviewEntity item;
  final VoidCallback? onTap;

  const ReviewsSocialSharingCardWidget({
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
