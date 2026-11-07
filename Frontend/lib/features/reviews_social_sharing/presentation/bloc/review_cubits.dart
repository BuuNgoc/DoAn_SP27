import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/review_usecases.dart';

enum ReviewSort {
  newest('Mới nhất'),
  highest('Điểm cao nhất'),
  lowest('Điểm thấp nhất'),
  helpful('Hữu ích nhất'),
  withPhotos('Có hình ảnh');

  const ReviewSort(this.label);
  final String label;
}

class ReviewListState extends Equatable {
  const ReviewListState({
    this.status = ViewStatus.initial,
    this.reviews = const [],
    this.sort = ReviewSort.newest,
    this.starFilter,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<Review> reviews;
  final ReviewSort sort;
  final int? starFilter;
  final String? errorMessage;

  ReviewSummary get summary => ReviewSummary.fromReviews(reviews);

  List<Review> get visible {
    var list = reviews.where((r) => starFilter == null || r.rating == starFilter).toList();
    switch (sort) {
      case ReviewSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ReviewSort.highest:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case ReviewSort.lowest:
        list.sort((a, b) => a.rating.compareTo(b.rating));
      case ReviewSort.helpful:
        list.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
      case ReviewSort.withPhotos:
        list = list.where((r) => r.photoCount > 0).toList();
    }
    return list;
  }

  ReviewListState copyWith({
    ViewStatus? status,
    List<Review>? reviews,
    ReviewSort? sort,
    int? Function()? starFilter,
    String? errorMessage,
  }) =>
      ReviewListState(
        status: status ?? this.status,
        reviews: reviews ?? this.reviews,
        sort: sort ?? this.sort,
        starFilter: starFilter != null ? starFilter() : this.starFilter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, reviews, sort, starFilter, errorMessage];
}

/// [FE-10] Danh sách đánh giá của một điểm đến (lọc, sắp xếp, báo cáo, xóa).
class DestinationReviewsCubit extends Cubit<ReviewListState> {
  DestinationReviewsCubit({
    required GetDestinationReviewsUseCase getReviews,
    required DeleteReviewUseCase delete,
    required ReportReviewUseCase report,
  })  : _getReviews = getReviews,
        _delete = delete,
        _report = report,
        super(const ReviewListState());

  final GetDestinationReviewsUseCase _getReviews;
  final DeleteReviewUseCase _delete;
  final ReportReviewUseCase _report;
  String? _destinationId;

  Future<void> load(String destinationId) async {
    _destinationId = destinationId;
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      emit(state.copyWith(status: ViewStatus.success, reviews: await _getReviews(destinationId)));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  Future<void> refresh() async {
    final id = _destinationId;
    if (id != null) await load(id);
  }

  void setSort(ReviewSort sort) => emit(state.copyWith(sort: sort));
  void setStarFilter(int? star) => emit(state.copyWith(starFilter: () => star == state.starFilter ? null : star));

  Future<String?> delete(String userId, Review review) async {
    try {
      await _delete(userId: userId, destinationId: review.destinationId, reviewId: review.id);
      emit(state.copyWith(reviews: state.reviews.where((r) => r.id != review.id).toList()));
      return null;
    } catch (e) {
      return errorMessageOf(e);
    }
  }

  Future<String?> report(String userId, Review review, ReportReason reason, String? note) async {
    try {
      await _report(userId: userId, destinationId: review.destinationId, reviewId: review.id, reason: reason, note: note);
      return null;
    } catch (e) {
      return errorMessageOf(e);
    }
  }
}

/// [FE-10] Đánh giá cá nhân của người dùng.
class MyReviewsCubit extends Cubit<ReviewListState> {
  MyReviewsCubit({required GetMyReviewsUseCase getMine, required DeleteReviewUseCase delete})
      : _getMine = getMine,
        _delete = delete,
        super(const ReviewListState());

  final GetMyReviewsUseCase _getMine;
  final DeleteReviewUseCase _delete;
  String? _userId;

  Future<void> load(String userId) async {
    _userId = userId;
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      emit(state.copyWith(status: ViewStatus.success, reviews: await _getMine(userId)));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  Future<void> refresh() async {
    final id = _userId;
    if (id != null) await load(id);
  }

  Future<String?> delete(Review review) async {
    final userId = _userId;
    if (userId == null) return 'Vui lòng đăng nhập.';
    try {
      await _delete(userId: userId, destinationId: review.destinationId, reviewId: review.id);
      emit(state.copyWith(reviews: state.reviews.where((r) => r.id != review.id).toList()));
      return null;
    } catch (e) {
      return errorMessageOf(e);
    }
  }
}

class WriteReviewState extends Equatable {
  const WriteReviewState({this.status = ViewStatus.initial, this.existing, this.submitting = false, this.errorMessage});

  final ViewStatus status;
  final Review? existing;
  final bool submitting;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, existing, submitting, errorMessage];
}

/// [FE-10] Viết mới / chỉnh sửa đánh giá.
class WriteReviewCubit extends Cubit<WriteReviewState> {
  WriteReviewCubit({required GetReviewUseCase getReview, required SubmitReviewUseCase submit})
      : _getReview = getReview,
        _submit = submit,
        super(const WriteReviewState());

  final GetReviewUseCase _getReview;
  final SubmitReviewUseCase _submit;

  Future<void> init(String destinationId, String? reviewId) async {
    if (reviewId == null) {
      emit(const WriteReviewState(status: ViewStatus.success));
      return;
    }
    emit(const WriteReviewState(status: ViewStatus.loading));
    try {
      final r = await _getReview(destinationId, reviewId);
      if (r == null) {
        emit(const WriteReviewState(status: ViewStatus.failure, errorMessage: 'Không tìm thấy đánh giá cần sửa.'));
        return;
      }
      emit(WriteReviewState(status: ViewStatus.success, existing: r));
    } catch (e) {
      emit(WriteReviewState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  Future<String?> submit({
    required String userId,
    required String authorName,
    String? nationality,
    required ReviewDraft draft,
  }) async {
    emit(WriteReviewState(status: state.status, existing: state.existing, submitting: true));
    try {
      final r = await _submit(userId: userId, authorName: authorName, nationality: nationality, draft: draft);
      emit(WriteReviewState(status: state.status, existing: r));
      return null;
    } catch (e) {
      emit(WriteReviewState(status: state.status, existing: state.existing));
      return errorMessageOf(e);
    }
  }
}
