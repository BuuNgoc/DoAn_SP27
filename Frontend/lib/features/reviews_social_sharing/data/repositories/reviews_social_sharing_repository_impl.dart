import '../../domain/entities/reviews_social_sharing_entity.dart';
import '../../domain/repositories/reviews_social_sharing_repository.dart';
import '../datasources/reviews_social_sharing_remote_data_source.dart';

/// [FE-10, FE-11] Repository Implementation for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
class ReviewsSocialSharingRepositoryImpl implements ReviewsSocialSharingRepository {
  final ReviewsSocialSharingRemoteDataSource remoteDataSource;

  ReviewsSocialSharingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReviewEntity>> getItems() async {
    return await remoteDataSource.fetchItems();
  }

  @override
  Future<ReviewEntity> getItemById(String id) async {
    return await remoteDataSource.fetchItemById(id);
  }
}
