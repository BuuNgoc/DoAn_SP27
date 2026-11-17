import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  const ReviewRepositoryImpl(this._remote);
  final ReviewRemoteDataSource _remote;

  @override
  Future<List<Review>> getDestinationReviews(String destinationId) => _remote.getDestinationReviews(destinationId);

  @override
  Future<List<Review>> getMyReviews(String userId) => _remote.getMyReviews(userId);

  @override
  Future<Review?> getReview(String destinationId, String reviewId) => _remote.getReview(destinationId, reviewId);

  @override
  Future<Review> submitReview({
    required String userId,
    required String authorName,
    String? nationality,
    required ReviewDraft draft,
  }) =>
      _remote.submitReview(userId: userId, authorName: authorName, nationality: nationality, draft: draft);

  @override
  Future<void> deleteReview({required String userId, required String destinationId, required String reviewId}) =>
      _remote.deleteReview(userId: userId, destinationId: destinationId, reviewId: reviewId);

  @override
  Future<void> reportReview({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) =>
      _remote.reportReview(userId: userId, destinationId: destinationId, reviewId: reviewId, reason: reason, note: note);
}
