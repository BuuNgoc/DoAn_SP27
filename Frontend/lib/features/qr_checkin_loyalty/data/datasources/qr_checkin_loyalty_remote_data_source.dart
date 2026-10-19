import '../models/qr_checkin_loyalty_model.dart';
import '../../../../core/services/firestore_service.dart';

/// [FE-08, FE-09] Remote DataSource for QR Check-in & Loyalty Points (Scanner, History, Points, Redeem Rewards)
abstract class QrCheckinLoyaltyRemoteDataSource {
  Future<List<CheckinLoyaltyModel>> fetchItems();
  Future<CheckinLoyaltyModel> fetchItemById(String id);
}

class QrCheckinLoyaltyRemoteDataSourceImpl implements QrCheckinLoyaltyRemoteDataSource {
  final FirestoreService firestoreService;

  QrCheckinLoyaltyRemoteDataSourceImpl(this.firestoreService);

  @override
  Future<List<CheckinLoyaltyModel>> fetchItems() async {
    // Stub implementation for FE-08, FE-09
    return [];
  }

  @override
  Future<CheckinLoyaltyModel> fetchItemById(String id) async {
    // Stub implementation for FE-08, FE-09
    return CheckinLoyaltyModel(id: id, title: 'Item $id');
  }
}
