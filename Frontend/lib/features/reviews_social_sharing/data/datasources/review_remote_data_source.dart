import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/review.dart';

/// Ánh xạ Firestore ⇄ [Review].
class ReviewModel {
  ReviewModel._();

  static Review fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? const <String, dynamic>{};
    return Review(
      id: doc.id,
      destinationId: (m['destinationId'] as String?) ?? doc.reference.parent.parent?.id ?? '',
      destinationName: (m['destinationName'] as String?) ?? '',
      userId: (m['userId'] as String?) ?? '',
      authorName: (m['authorName'] as String?) ?? 'Du khách',
      authorNationality: m['authorNationality'] as String?,
      rating: (m['rating'] as num?)?.toInt() ?? 0,
      content: (m['content'] as String?) ?? '',
      photos: List<String>.from((m['photos'] as List?) ?? const []),
      visitType: m['visitType'] as String?,
      helpfulCount: (m['helpfulCount'] as num?)?.toInt() ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

abstract class ReviewRemoteDataSource {
  Future<List<Review>> getDestinationReviews(String destinationId);
  Future<List<Review>> getMyReviews(String userId);
  Future<Review?> getReview(String destinationId, String reviewId);
  Future<Review> submitReview({required String userId, required String authorName, String? nationality, required ReviewDraft draft});
  Future<void> deleteReview({required String userId, required String destinationId, required String reviewId});
  Future<void> reportReview({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  });
}

/// Dữ liệu mẫu trong bộ nhớ (đăng ký lazySingleton để giữ trạng thái giữa các màn hình).
class MockReviewRemoteDataSource implements ReviewRemoteDataSource {
  MockReviewRemoteDataSource() : _reviews = ReviewSampleData.build();

  final List<Review> _reviews;
  final Map<String, Set<String>> _reportsByUser = {};
  int _seq = 100;

  List<Review> _sorted(Iterable<Review> list) => list.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<List<Review>> getDestinationReviews(String destinationId) async {
    await simulateLatency();
    return _sorted(_reviews.where((r) => r.destinationId == destinationId));
  }

  @override
  Future<List<Review>> getMyReviews(String userId) async {
    await simulateLatency();
    return _sorted(_reviews.where((r) => r.userId == userId));
  }

  @override
  Future<Review?> getReview(String destinationId, String reviewId) async {
    await simulateLatency(const Duration(milliseconds: 200));
    return _reviews.where((r) => r.id == reviewId).firstOrNull;
  }

  @override
  Future<Review> submitReview({
    required String userId,
    required String authorName,
    String? nationality,
    required ReviewDraft draft,
  }) async {
    await simulateLatency(const Duration(milliseconds: 800));
    if (draft.isEditing) {
      final i = _reviews.indexWhere((r) => r.id == draft.reviewId);
      if (i < 0) throw const ServerException('Không tìm thấy đánh giá cần sửa.');
      final old = _reviews[i];
      if (old.userId != userId) throw const PermissionException('Bạn chỉ có thể sửa đánh giá của chính mình.');
      final updated = Review(
        id: old.id,
        destinationId: old.destinationId,
        destinationName: old.destinationName,
        userId: old.userId,
        authorName: authorName,
        authorNationality: nationality,
        rating: draft.rating,
        content: draft.content.trim(),
        photos: draft.keptPhotos,
        localPhotos: draft.newPhotos,
        visitType: draft.visitType,
        helpfulCount: old.helpfulCount,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _reviews[i] = updated;
      return updated;
    }
    // LI: mỗi tài khoản chỉ có một đánh giá cho mỗi điểm đến.
    final existed = _reviews.any((r) => r.userId == userId && r.destinationId == draft.destinationId);
    if (existed) {
      throw const ServerException('Bạn đã đánh giá điểm đến này. Hãy chỉnh sửa đánh giá cũ trong mục “Đánh giá của tôi”.');
    }
    final review = Review(
      id: 'rv_${_seq++}',
      destinationId: draft.destinationId,
      destinationName: draft.destinationName,
      userId: userId,
      authorName: authorName,
      authorNationality: nationality,
      rating: draft.rating,
      content: draft.content.trim(),
      photos: draft.keptPhotos,
      localPhotos: draft.newPhotos,
      visitType: draft.visitType,
      createdAt: DateTime.now(),
    );
    _reviews.add(review);
    return review;
  }

  @override
  Future<void> deleteReview({required String userId, required String destinationId, required String reviewId}) async {
    await simulateLatency();
    final r = _reviews.where((e) => e.id == reviewId).firstOrNull;
    if (r == null) throw const ServerException('Đánh giá không còn tồn tại.');
    if (r.userId != userId) throw const PermissionException('Bạn chỉ có thể xóa đánh giá của chính mình.');
    _reviews.remove(r);
  }

  @override
  Future<void> reportReview({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) async {
    await simulateLatency();
    final reported = _reportsByUser.putIfAbsent(userId, () => {});
    if (reported.contains(reviewId)) {
      throw const ServerException('Bạn đã báo cáo đánh giá này trước đó. Ban quản trị đang xem xét.');
    }
    reported.add(reviewId);
  }
}

/// Kết nối Firestore + Firebase Storage thật.
class FirestoreReviewRemoteDataSource implements ReviewRemoteDataSource {
  FirestoreReviewRemoteDataSource({FirebaseFirestore? db, FirebaseStorage? storage})
      : _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _col(String destinationId) => _db
      .collection(FirestoreCollections.destinations)
      .doc(destinationId)
      .collection(FirestoreCollections.subReviews);

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Không kết nối được máy chủ.', code: e.code);
    }
  }

  @override
  Future<List<Review>> getDestinationReviews(String destinationId) => _guard(() async {
        final snap = await _col(destinationId)
            .where('status', isEqualTo: 'visible')
            .limit(100)
            .get();
        if (snap.docs.isEmpty) {
          final sample = ReviewSampleData.build().where((r) => r.destinationId == destinationId).toList();
          if (sample.isNotEmpty) return sample;
        }
        final list = snap.docs.map(ReviewModel.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  @override
  Future<List<Review>> getMyReviews(String userId) => _guard(() async {
        try {
          final snap = await _db
              .collectionGroup(FirestoreCollections.subReviews)
              .where('userId', isEqualTo: userId)
              .get();
          final list = snap.docs.map(ReviewModel.fromDoc).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        } catch (_) {
          return ReviewSampleData.build().where((r) => r.userId == userId).toList();
        }
      });

  @override
  Future<Review?> getReview(String destinationId, String reviewId) => _guard(() async {
        final doc = await _col(destinationId).doc(reviewId).get();
        return doc.exists ? ReviewModel.fromDoc(doc) : null;
      });

  @override
  Future<Review> submitReview({
    required String userId,
    required String authorName,
    String? nationality,
    required ReviewDraft draft,
  }) =>
      _guard(() async {
        // Dùng userId làm id tài liệu → mỗi người một đánh giá cho mỗi điểm đến.
        final ref = _col(draft.destinationId).doc(draft.reviewId ?? userId);
        final urls = <String>[...draft.keptPhotos];
        for (var i = 0; i < draft.newPhotos.length; i++) {
          final path = 'reviews/${draft.destinationId}/${ref.id}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final task = await _storage.ref(path).putData(draft.newPhotos[i], SettableMetadata(contentType: 'image/jpeg'));
          urls.add(await task.ref.getDownloadURL());
        }
        final data = <String, dynamic>{
          'destinationId': draft.destinationId,
          'destinationName': draft.destinationName,
          'userId': userId,
          'authorName': authorName,
          'authorNationality': nationality,
          'rating': draft.rating,
          'content': draft.content.trim(),
          'photos': urls,
          'visitType': draft.visitType,
          'status': 'visible',
          if (draft.isEditing) 'updatedAt': FieldValue.serverTimestamp() else 'createdAt': FieldValue.serverTimestamp(),
        };
        await ref.set(data, SetOptions(merge: true));
        return ReviewModel.fromDoc(await ref.get());
      });

  @override
  Future<void> deleteReview({required String userId, required String destinationId, required String reviewId}) =>
      _guard(() => _col(destinationId).doc(reviewId).delete());

  @override
  Future<void> reportReview({
    required String userId,
    required String destinationId,
    required String reviewId,
    required ReportReason reason,
    String? note,
  }) =>
      _guard(() => _col(destinationId).doc(reviewId).collection('reports').doc(userId).set({
            'reporterId': userId,
            'reason': reason.name,
            'note': note,
            'createdAt': FieldValue.serverTimestamp(),
          }));
}

/// Đánh giá mẫu cho các điểm đến Ngũ Hành Sơn (tên người đánh giá là hư cấu).
class ReviewSampleData {
  ReviewSampleData._();

  static const String demoUserId = 'demo-tourist-001';

  static List<Review> build() {
    final now = DateTime.now();
    DateTime ago(int days, [int hours = 0]) => now.subtract(Duration(days: days, hours: hours));
    return [
      Review(
        id: 'rv_001',
        destinationId: 'ngu_hanh_son',
        destinationName: 'Danh thắng Ngũ Hành Sơn',
        userId: 'u_bao_ngoc',
        authorName: 'Trần Bảo Ngọc',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Cảnh quan tuyệt đẹp, leo lên Vọng Giang Đài nhìn thấy cả sông Cổ Cò và biển Non Nước. Nên đi buổi sáng sớm để tránh nắng, mang giày đế bám vì bậc đá khá trơn.',
        photos: const [AppImages.marbleMountains],
        visitType: 'Gia đình',
        helpfulCount: 42,
        createdAt: ago(3),
      ),
      Review(
        id: 'rv_002',
        destinationId: 'ngu_hanh_son',
        destinationName: 'Danh thắng Ngũ Hành Sơn',
        userId: 'u_emily',
        authorName: 'Emily Carter',
        authorNationality: 'Vương quốc Anh',
        rating: 4,
        content:
            'Một nơi rất đáng ghé khi đến Đà Nẵng. Thang máy giúp tiết kiệm sức nhưng nên đi bộ xuống để ngắm các chùa nhỏ. Có hơi đông khách vào buổi trưa.',
        visitType: 'Cặp đôi',
        helpfulCount: 18,
        createdAt: ago(9),
      ),
      Review(
        id: 'rv_003',
        destinationId: 'ngu_hanh_son',
        destinationName: 'Danh thắng Ngũ Hành Sơn',
        userId: 'u_jihoon',
        authorName: 'Park Ji-hoon',
        authorNationality: 'Hàn Quốc',
        rating: 5,
        content:
            'Hệ thống hang động rất ấn tượng, đặc biệt là Động Huyền Không. Bản thuyết minh tiếng Hàn trên ứng dụng rất hữu ích cho gia đình tôi.',
        visitType: 'Gia đình',
        helpfulCount: 25,
        createdAt: ago(15),
      ),
      Review(
        id: 'rv_004',
        destinationId: 'dong_huyen_khong',
        destinationName: 'Động Huyền Không',
        userId: 'u_hoang_nam',
        authorName: 'Lê Hoàng Nam',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Đến khoảng 9 – 10 giờ sáng sẽ thấy những cột nắng chiếu xuyên qua vòm động, chụp ảnh cực đẹp. Không gian linh thiêng, mọi người nên giữ trật tự.',
        photos: const [AppImages.huyenKhongCave],
        visitType: 'Bạn bè',
        helpfulCount: 61,
        createdAt: ago(2, 5),
      ),
      Review(
        id: 'rv_005',
        destinationId: 'dong_huyen_khong',
        destinationName: 'Động Huyền Không',
        userId: 'u_lihua',
        authorName: 'Lý Hoa',
        authorNationality: 'Trung Quốc',
        rating: 4,
        content:
            'Hang động rất đẹp và mát mẻ. Lối đi xuống hơi dốc, người lớn tuổi cần chú ý. Rất thích phần ảnh VR360 trên ứng dụng để xem trước.',
        visitType: 'Gia đình',
        helpfulCount: 9,
        createdAt: ago(20),
      ),
      Review(
        id: 'rv_006',
        destinationId: 'chua_linh_ung_non_nuoc',
        destinationName: 'Chùa Linh Ứng Non Nước',
        userId: 'u_thu_ha',
        authorName: 'Nguyễn Thu Hà',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Không gian chùa thanh tịnh, kiến trúc trang nghiêm. Du khách nhớ ăn mặc lịch sự, kín đáo khi vào chính điện. Có nhiều cây xanh và chỗ ngồi nghỉ.',
        photos: const [AppImages.linhUngPagoda],
        visitType: 'Gia đình',
        helpfulCount: 33,
        createdAt: ago(5),
      ),
      Review(
        id: 'rv_007',
        destinationId: 'lang_da_non_nuoc',
        destinationName: 'Làng đá mỹ nghệ Non Nước',
        userId: 'u_quoc_bao',
        authorName: 'Phạm Quốc Bảo',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Được xem nghệ nhân chế tác trực tiếp, rất tỉ mỉ. Tôi đã tham gia workshop khắc đá cơ bản 2 giờ và mang về một chiếc chặn giấy tự làm. Rất đáng trải nghiệm!',
        photos: const [AppImages.artisanWorkshop, AppImages.nonNuocVillage],
        visitType: 'Bạn bè',
        helpfulCount: 27,
        createdAt: ago(7),
      ),
      Review(
        id: 'rv_008',
        destinationId: 'lang_da_non_nuoc',
        destinationName: 'Làng đá mỹ nghệ Non Nước',
        userId: 'u_sophie',
        authorName: 'Sophie Martin',
        authorNationality: 'Pháp',
        rating: 4,
        content:
            'Nhiều sản phẩm đá mỹ nghệ đẹp, giá cả đa dạng. Nên hỏi kỹ về dịch vụ vận chuyển quốc tế nếu mua tượng lớn. Nhân viên thân thiện và nhiệt tình.',
        visitType: 'Cặp đôi',
        helpfulCount: 11,
        createdAt: ago(12),
      ),
      Review(
        id: 'rv_009',
        destinationId: 'bai_bien_son_thuy',
        destinationName: 'Bãi biển Sơn Thủy',
        userId: 'u_gia_huy',
        authorName: 'Võ Gia Huy',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Bãi biển sạch, nước trong xanh, có chòi cứu hộ và khu vực tắm an toàn được cắm cờ rõ ràng. Buổi chiều tầm 16 giờ tắm là đẹp nhất.',
        photos: const [AppImages.sonThuyBeach],
        visitType: 'Gia đình',
        helpfulCount: 38,
        createdAt: ago(4),
      ),
      Review(
        id: 'rv_010',
        destinationId: 'bai_bien_son_thuy',
        destinationName: 'Bãi biển Sơn Thủy',
        userId: 'u_daniel',
        authorName: 'Daniel Kim',
        authorNationality: 'Úc',
        rating: 4,
        content:
            'Great beach, ít đông hơn bãi Mỹ Khê. Dịch vụ thuê ghế và tắm nước ngọt tiện lợi. Lưu ý có sóng lớn vào mùa mưa, hãy tắm trong khu vực có cứu hộ.',
        visitType: 'Bạn bè',
        helpfulCount: 7,
        createdAt: ago(18),
      ),
      Review(
        id: 'rv_011',
        destinationId: 'pho_an_thuong',
        destinationName: 'Phố Tây An Thượng',
        userId: 'u_khanh_linh',
        authorName: 'Đỗ Khánh Linh',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Khu phố sôi động về đêm, nhiều quán cà phê, nhà hàng đa quốc gia và quán bar nhạc sống. Đồ ăn ngon, giá hợp lý. Nên đi bộ để cảm nhận không khí.',
        photos: const [AppImages.anThuongStreet],
        visitType: 'Bạn bè',
        helpfulCount: 22,
        createdAt: ago(6),
      ),
      Review(
        id: 'rv_012',
        destinationId: 'pho_an_thuong',
        destinationName: 'Phố Tây An Thượng',
        userId: 'u_tom',
        authorName: 'Tom Wilson',
        authorNationality: 'Hoa Kỳ',
        rating: 3,
        content:
            'Không khí vui nhộn nhưng khá ồn vào cuối tuần, chỗ đỗ xe máy hơi chật. Phù hợp với người thích nightlife hơn là gia đình có trẻ nhỏ.',
        visitType: 'Một mình',
        helpfulCount: 5,
        createdAt: ago(25),
      ),
      // ── Đánh giá của tài khoản demo ──────────────────────────────────
      Review(
        id: 'rv_demo_001',
        destinationId: 'chua_linh_ung_non_nuoc',
        destinationName: 'Chùa Linh Ứng Non Nước',
        userId: demoUserId,
        authorName: 'Nguyễn Minh Anh',
        authorNationality: 'Việt Nam',
        rating: 5,
        content:
            'Lần thứ hai quay lại chùa và vẫn rất ấn tượng với tượng Phật Quán Thế Âm hướng ra biển. Ứng dụng thuyết minh giúp tôi hiểu thêm nhiều về lịch sử ngôi chùa.',
        visitType: 'Gia đình',
        helpfulCount: 4,
        createdAt: ago(10),
      ),
      Review(
        id: 'rv_demo_002',
        destinationId: 'bai_bien_non_nuoc',
        destinationName: 'Bãi biển Non Nước',
        userId: demoUserId,
        authorName: 'Nguyễn Minh Anh',
        authorNationality: 'Việt Nam',
        rating: 4,
        content:
            'Bãi biển yên tĩnh, cát trắng mịn, phù hợp để đi dạo buổi sáng. Mong có thêm thùng rác và nhà vệ sinh công cộng dọc bờ biển.',
        visitType: 'Cặp đôi',
        helpfulCount: 2,
        createdAt: ago(30),
        updatedAt: ago(28),
      ),
    ];
  }
}
