import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// [FE-10] Đánh giá của du khách cho một điểm đến
/// (Firestore: `destinations/{destinationId}/reviews/{reviewId}`).
class Review extends Equatable {
  const Review({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.content,
    required this.createdAt,
    this.authorNationality,
    this.photos = const [],
    this.localPhotos = const [],
    this.updatedAt,
    this.helpfulCount = 0,
    this.visitType,
  });

  final String id;
  final String destinationId;
  final String destinationName;
  final String userId;
  final String authorName;
  final String? authorNationality;
  final int rating;
  final String content;

  /// Ảnh đã tải lên (đường dẫn asset hoặc URL Firebase Storage).
  final List<String> photos;

  /// Ảnh vừa chọn từ thiết bị (chỉ dùng ở chế độ dữ liệu mẫu).
  final List<Uint8List> localPhotos;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;

  /// Ví dụ: "Gia đình", "Cặp đôi", "Một mình", "Bạn bè".
  final String? visitType;

  bool get isEdited => updatedAt != null;
  int get photoCount => photos.length + localPhotos.length;

  String get authorInitials {
    final parts = authorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => [id, rating, content, photos, localPhotos.length, updatedAt, helpfulCount];
}

/// Thống kê điểm đánh giá của một điểm đến.
class ReviewSummary extends Equatable {
  const ReviewSummary({required this.average, required this.total, required this.distribution});

  factory ReviewSummary.fromReviews(List<Review> reviews) {
    final dist = {for (var i = 1; i <= 5; i++) i: 0};
    for (final r in reviews) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    final avg = reviews.isEmpty ? 0.0 : reviews.fold<int>(0, (s, r) => s + r.rating) / reviews.length;
    return ReviewSummary(average: avg, total: reviews.length, distribution: dist);
  }

  final double average;
  final int total;

  /// Số lượt đánh giá theo từng mức sao (1..5).
  final Map<int, int> distribution;

  double ratioOf(int star) => total == 0 ? 0 : (distribution[star] ?? 0) / total;

  @override
  List<Object?> get props => [average, total, distribution];
}

/// Dữ liệu gửi khi viết mới / chỉnh sửa đánh giá.
class ReviewDraft {
  const ReviewDraft({
    required this.destinationId,
    required this.destinationName,
    required this.rating,
    required this.content,
    this.reviewId,
    this.visitType,
    this.keptPhotos = const [],
    this.newPhotos = const [],
  });

  final String? reviewId;
  final String destinationId;
  final String destinationName;
  final int rating;
  final String content;
  final String? visitType;
  final List<String> keptPhotos;
  final List<Uint8List> newPhotos;

  bool get isEditing => reviewId != null;
  int get photoCount => keptPhotos.length + newPhotos.length;
}

/// Lý do báo cáo đánh giá vi phạm.
enum ReportReason {
  spam('Spam hoặc quảng cáo'),
  offensive('Ngôn từ xúc phạm, thù ghét'),
  falseInfo('Thông tin sai sự thật'),
  irrelevant('Không liên quan đến điểm đến'),
  privacy('Lộ thông tin cá nhân người khác'),
  other('Lý do khác');

  const ReportReason(this.label);
  final String label;
}

/// Giới hạn nội dung đánh giá.
class ReviewRules {
  ReviewRules._();
  static const int minContentLength = 20;
  static const int maxContentLength = 1000;
  static const int maxPhotos = 5;
  static const List<String> visitTypes = ['Một mình', 'Cặp đôi', 'Gia đình', 'Bạn bè', 'Công tác'];
}
