import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetDestinationReviewsUseCase {
  const GetDestinationReviewsUseCase(this._r);
  final ReviewRepository _r;
  Future<List<Review>> call(String destinationId) => _r.getDestinationReviews(destinationId);
}

class GetMyReviewsUseCase {
  const GetMyReviewsUseCase(this._r);
  final ReviewRepository _r;
  Future<List<Review>> call(String userId) => _r.getMyReviews(userId);
}

class GetReviewUseCase {
  const GetReviewUseCase(this._r);
  final ReviewRepository _r;
  Future<Review?> call(String destinationId, String reviewId) => _r.getReview(destinationId, reviewId);
}

/// Viết mới hoặc cập nhật đánh giá (kiểm tra hợp lệ trước khi gửi).
class SubmitReviewUseCase {
  const SubmitReviewUseCase(this._r);
  final ReviewRepository _r;

  Future<Review> call({
    required String userId,
    required String authorName,
    String? nationality,
    required ReviewDraft draft,
  }) {
    if (draft.rating < 1 || draft.rating > 5) {
      throw ArgumentError('Vui lòng chấm từ 1 đến 5 sao.');
    }
    final length = draft.content.trim().length;
    if (length < ReviewRules.minContentLength) {
      throw ArgumentError('Nội dung đánh giá cần tối thiểu ${ReviewRules.minContentLength} ký tự.');
    }
    if (length > ReviewRules.maxContentLength) {
      throw ArgumentError('Nội dung đánh giá tối đa ${ReviewRules.maxContentLength} ký tự.');
    }
    if (draft.photoCount > ReviewRules.maxPhotos) {
      throw ArgumentError('Chỉ được đính kèm tối đa ${ReviewRules.maxPhotos} ảnh.');
    }
    return _r.submitReview(userId: userId, authorName: authorName, nationality: nationality, draft: draft);
  }
}

class DeleteReviewUseCase {
  const DeleteReviewUseCase(this._r);
  final ReviewRepository _r;
  Future<void> call({required String userId, required String destinationId, required String reviewId}) =>
      _r.deleteReview(userId: userId, destinationId: destinationId, reviewId: reviewId);
}

class ReportReviewUseCase {
  const ReportReviewUseCase(this._r);
  final ReviewRepository _r;
  Future<void> call({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) =>
      _r.reportReview(userId: userId, destinationId: destinationId, reviewId: reviewId, reason: reason, note: note);
}
