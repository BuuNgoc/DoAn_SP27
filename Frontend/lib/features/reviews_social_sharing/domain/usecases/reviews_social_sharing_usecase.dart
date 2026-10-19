import '../entities/reviews_social_sharing_entity.dart';
import '../repositories/reviews_social_sharing_repository.dart';

/// [FE-10, FE-11] Primary UseCase for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
class GetReviewsSocialSharingUseCase {
  final ReviewsSocialSharingRepository repository;

  GetReviewsSocialSharingUseCase(this.repository);

  Future<List<ReviewEntity>> execute() async {
    return await repository.getItems();
  }
}
