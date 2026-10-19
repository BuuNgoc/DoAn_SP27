import 'package:equatable/equatable.dart';

/// [FE-10, FE-11] Entity for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
class ReviewEntity extends Equatable {
  final String id;
  final String title;

  const ReviewEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
