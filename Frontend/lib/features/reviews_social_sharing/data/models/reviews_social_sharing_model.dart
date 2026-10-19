import '../../domain/entities/reviews_social_sharing_entity.dart';

/// [FE-10, FE-11] Data Model with Firestore serialization for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.title,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ReviewModel(
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
