import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getDestinationReviews(String destinationId);
  Future<List<Review>> getMyReviews(String userId);
  Future<Review?> getReview(String destinationId, String reviewId);
  Future<Review> submitReview({required String userId, required String authorName, String? nationality, required ReviewDraft draft});
  Future<void> deleteReview({required String userId, required String destinationId, required String reviewId});
  Future<void> reportReview({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  });
}
