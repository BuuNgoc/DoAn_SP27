import '../models/reviews_social_sharing_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-10, FE-11] Remote DataSource for Reviews & Social Sharing (Ratings, Photos, Moderation, Social Share)
abstract class ReviewsSocialSharingRemoteDataSource {
  Future<List<ReviewModel>> fetchItems();
  Future<ReviewModel> fetchItemById(String id);
}

class ReviewsSocialSharingRemoteDataSourceImpl implements ReviewsSocialSharingRemoteDataSource {
  final FirestoreService firestoreService;

  ReviewsSocialSharingRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<ReviewModel>> fetchItems() async {
    // Stub implementation for FE-10, FE-11
    return [];
  }

  @override
  Future<ReviewModel> fetchItemById(String id) async {
    // Stub implementation for FE-10, FE-11
    return ReviewModel(id: id, title: 'Item $id');
  }
}
