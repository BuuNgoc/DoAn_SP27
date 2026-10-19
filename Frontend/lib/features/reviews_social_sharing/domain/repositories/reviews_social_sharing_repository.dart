import 'reviews_social_sharing_entity.dart';

/// [FE-10, FE-11] Domain Repository Interface for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
abstract class ReviewsSocialSharingRepository {
  Future<List<ReviewEntity>> getItems();
  Future<ReviewEntity> getItemById(String id);
}
