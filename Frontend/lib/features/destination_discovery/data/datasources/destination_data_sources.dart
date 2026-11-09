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

/// [FE-02] Lưu danh sách id điểm đến vừa mở trong Hive (tối đa 10 mục, mới nhất lên đầu, không trùng).
/// Chỉ lưu LOCAL trên thiết bị (LI-05, LI-07) — không ghi Firestore.
class RecentlyViewedLocalDataSource {
  static const String boxName = 'recently_viewed_destinations';
  static const String idsKey = 'ids';
  static const int maxItems = 10;

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  static Future<void> init() => Hive.openBox<dynamic>(boxName);

  /// Tính danh sách mới khi mở một điểm đến: đưa [id] lên đầu, loại bỏ trùng lặp, cắt tối đa [max] mục.
  static List<String> computeUpdatedIds(
    List<String> current,
    String id, {
    int max = maxItems,
  }) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return List<String>.unmodifiable(current.take(max));
    final updated = <String>[
      trimmed,
      ...current.where((existing) => existing != trimmed),
    ];
    if (updated.length > max) {
      return List<String>.unmodifiable(updated.sublist(0, max));
    }
    return List<String>.unmodifiable(updated);
  }

  List<String> getIds() {
    if (!Hive.isBoxOpen(boxName)) return const [];
    final raw = _box.get(idsKey);
    if (raw is List) {
      return List<String>.unmodifiable(raw.whereType<String>().take(maxItems));
    }
    return const [];
  }

  Future<List<String>> add(String id) async {
    final next = computeUpdatedIds(getIds(), id);
    if (Hive.isBoxOpen(boxName)) {
      await _box.put(idsKey, next);
    }
    return next;
  }

  Future<void> clear() async {
    if (Hive.isBoxOpen(boxName)) {
      await _box.delete(idsKey);
    }
  }
}
