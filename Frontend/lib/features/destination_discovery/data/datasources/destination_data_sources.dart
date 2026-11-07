import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../models/destination_model.dart';
import 'destination_sample_data.dart';

/// [FE-02] Nguồn dữ liệu điểm đến từ xa.
abstract class DestinationRemoteDataSource {
  Future<List<DestinationModel>> fetchDestinations();
}

class MockDestinationRemoteDataSource implements DestinationRemoteDataSource {
  @override
  Future<List<DestinationModel>> fetchDestinations() async {
    await simulateLatency();
    return DestinationSampleData.destinations;
  }
}

class FirestoreDestinationRemoteDataSource implements DestinationRemoteDataSource {
  FirestoreDestinationRemoteDataSource([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<DestinationModel>> fetchDestinations() async {
    try {
      final snap = await _firestore
          .collection(FirestoreCollections.destinations)
          .where('isPublished', isEqualTo: true)
          .get();
      if (snap.docs.isEmpty) {
        return DestinationSampleData.destinations;
      }
      return snap.docs.map((d) => DestinationModel.fromFirestore(d.data(), d.id)).toList();
    } on FirebaseException catch (_) {
      return DestinationSampleData.destinations;
    }
  }
}

/// Lưu id điểm đến yêu thích trong Hive → hoạt động hoàn toàn ngoại tuyến.
class FavoritesLocalDataSource {
  static const boxName = 'favorite_destinations';

  Box<bool> get _box => Hive.box<bool>(boxName);

  static Future<void> init() => Hive.openBox<bool>(boxName);

  Set<String> getIds() => _box.keys.cast<String>().toSet();

  Future<bool> toggle(String id) async {
    if (_box.containsKey(id)) {
      await _box.delete(id);
      return false;
    }
    await _box.put(id, true);
    return true;
  }
}
