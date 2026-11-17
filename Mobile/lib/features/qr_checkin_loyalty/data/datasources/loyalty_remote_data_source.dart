import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/loyalty_entities.dart';

/// [FE-08, FE-09] Nguồn dữ liệu check-in & điểm thưởng.
abstract class LoyaltyRemoteDataSource {
  Future<List<CheckinPoint>> fetchPoints();
  Future<List<CheckinRecord>> fetchHistory(String userId);

  /// Ghi nhận check-in, trả về bản ghi mới (máy chủ kiểm tra trùng lặp trong ngày).
  Future<CheckinRecord> checkIn(String userId, String pointId);
  Future<LoyaltySummary> fetchSummary(String userId);
  Future<List<Reward>> fetchRewards();
  Future<Redemption> redeem(String userId, String rewardId);
  Future<List<Redemption>> fetchRedemptions(String userId);
}

String _code(String prefix) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final r = Random();
  return '$prefix-${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
}

class MockLoyaltyRemoteDataSource implements LoyaltyRemoteDataSource {
  MockLoyaltyRemoteDataSource() {
    final now = DateTime.now();
    _history['demo-tourist-001'] = [
      CheckinRecord(
        id: 'ck_01',
        pointId: 'cp_huyen_khong',
        pointName: 'Động Huyền Không',
        pointsEarned: 50,
        checkedInAt: now.subtract(const Duration(days: 12, hours: 3)),
      ),
      CheckinRecord(
        id: 'ck_02',
        pointId: 'cp_vong_giang',
        pointName: 'Vọng Giang Đài',
        pointsEarned: 50,
        checkedInAt: now.subtract(const Duration(days: 12, hours: 2)),
      ),
      CheckinRecord(
        id: 'ck_03',
        pointId: 'cp_son_thuy',
        pointName: 'Bãi biển Sơn Thủy',
        pointsEarned: 30,
        checkedInAt: now.subtract(const Duration(days: 4)),
      ),
    ];
    _balance['demo-tourist-001'] = (available: 380, lifetime: 680);
    _redemptions['demo-tourist-001'] = [
      Redemption(
        id: 'rd_01',
        rewardId: 'rw_ve_thang_may',
        rewardTitle: 'Vé thang máy núi Thủy Sơn',
        rewardImage: AppImages.marbleMountains,
        pointsSpent: 150,
        code: 'RW-9QK3TA',
        redeemedAt: now.subtract(const Duration(days: 12)),
        expiresAt: now.subtract(const Duration(days: 2)),
        status: RedemptionStatus.used,
        pickupLocation: 'Quầy vé thang máy núi Thủy Sơn',
      ),
    ];
  }

  final Map<String, List<CheckinRecord>> _history = {};
  final Map<String, ({int available, int lifetime})> _balance = {};
  final Map<String, List<Redemption>> _redemptions = {};
  late final Map<String, Reward> _rewards = {for (final r in LoyaltySampleData.rewards) r.id: r};

  @override
  Future<List<CheckinPoint>> fetchPoints() async {
    await simulateLatency();
    return LoyaltySampleData.points;
  }

  @override
  Future<List<CheckinRecord>> fetchHistory(String userId) async {
    await simulateLatency();
    return [...?_history[userId]]..sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));
  }

  @override
  Future<CheckinRecord> checkIn(String userId, String pointId) async {
    await simulateLatency();
    final point = LoyaltySampleData.points.where((p) => p.id == pointId).firstOrNull;
    if (point == null) throw const ServerException('Mã QR không hợp lệ hoặc điểm check-in đã ngừng hoạt động.');
    final today = DateTime.now();
    final list = _history.putIfAbsent(userId, () => []);
    final already = list.any((r) =>
        r.pointId == pointId &&
        r.checkedInAt.year == today.year &&
        r.checkedInAt.month == today.month &&
        r.checkedInAt.day == today.day);
    if (already) {
      throw ServerException('Bạn đã check-in tại ${point.name} hôm nay. Hãy quay lại vào ngày mai nhé!');
    }
    final record = CheckinRecord(
      id: 'ck_${today.millisecondsSinceEpoch}',
      pointId: point.id,
      pointName: point.name,
      pointsEarned: point.points,
      checkedInAt: today,
    );
    list.add(record);
    final b = _balance[userId] ?? (available: 0, lifetime: 0);
    _balance[userId] = (available: b.available + point.points, lifetime: b.lifetime + point.points);
    return record;
  }

  @override
  Future<LoyaltySummary> fetchSummary(String userId) async {
    await simulateLatency();
    final b = _balance[userId] ?? (available: 0, lifetime: 0);
    return LoyaltySummary(availablePoints: b.available, lifetimePoints: b.lifetime);
  }

  @override
  Future<List<Reward>> fetchRewards() async {
    await simulateLatency();
    return _rewards.values.toList();
  }

  @override
  Future<Redemption> redeem(String userId, String rewardId) async {
    await simulateLatency();
    final reward = _rewards[rewardId];
    if (reward == null) throw const ServerException('Phần thưởng không tồn tại.');
    if (!reward.inStock) throw const ServerException('Phần thưởng đã hết, vui lòng chọn quà khác.');
    final b = _balance[userId] ?? (available: 0, lifetime: 0);
    if (b.available < reward.pointsCost) {
      throw ServerException('Bạn cần thêm ${reward.pointsCost - b.available} điểm để đổi phần quà này.');
    }
    _balance[userId] = (available: b.available - reward.pointsCost, lifetime: b.lifetime);
    _rewards[rewardId] = Reward(
      id: reward.id,
      title: reward.title,
      description: reward.description,
      pointsCost: reward.pointsCost,
      image: reward.image,
      category: reward.category,
      stock: reward.stock - 1,
      partner: reward.partner,
      pickupLocation: reward.pickupLocation,
      terms: reward.terms,
    );
    final now = DateTime.now();
    final redemption = Redemption(
      id: 'rd_${now.millisecondsSinceEpoch}',
      rewardId: reward.id,
      rewardTitle: reward.title,
      rewardImage: reward.image,
      pointsSpent: reward.pointsCost,
      code: _code('RW'),
      redeemedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
      status: RedemptionStatus.ready,
      pickupLocation: reward.pickupLocation,
    );
    _redemptions.putIfAbsent(userId, () => []).add(redemption);
    return redemption;
  }

  @override
  Future<List<Redemption>> fetchRedemptions(String userId) async {
    await simulateLatency();
    return [...?_redemptions[userId]]..sort((a, b) => b.redeemedAt.compareTo(a.redeemedAt));
  }
}

/// Bản Firebase: đọc từ Firestore, ghi qua Cloud Functions để chống gian lận điểm.
class FirebaseLoyaltyRemoteDataSource implements LoyaltyRemoteDataSource {
  FirebaseLoyaltyRemoteDataSource({FirebaseFirestore? db, FirebaseFunctions? functions})
      : _db = db ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseFunctionsException catch (e) {
      throw ServerException(e.message ?? 'Không thực hiện được yêu cầu.', code: e.code);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Không kết nối được máy chủ.', code: e.code);
    }
  }

  DateTime _date(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();

  @override
  Future<List<CheckinPoint>> fetchPoints() => _guard(() async {
        final snap = await _db.collection(FirestoreCollections.checkinPoints).where('isActive', isEqualTo: true).get();
        if (snap.docs.isEmpty) {
          return LoyaltySampleData.points;
        }
        return snap.docs
            .map((d) => CheckinPoint(
                  id: d.id,
                  name: (d['name'] ?? '').toString(),
                  area: (d.data()['area'] ?? '').toString(),
                  description: (d.data()['description'] ?? '').toString(),
                  points: (d.data()['points'] as num? ?? 0).toInt(),
                  image: (d.data()['imageUrl'] ?? '').toString(),
                  destinationId: d.data()['destinationId']?.toString(),
                ))
            .toList();
      });

  @override
  Future<List<CheckinRecord>> fetchHistory(String userId) => _guard(() async {
        final snap = await _db
            .collection(FirestoreCollections.checkinRecords)
            .where('userId', isEqualTo: userId)
            .get();
        final list = snap.docs
            .map((d) => CheckinRecord(
                  id: d.id,
                  pointId: (d.data()['pointId'] ?? '').toString(),
                  pointName: (d.data()['pointName'] ?? '').toString(),
                  pointsEarned: (d.data()['pointsEarned'] as num? ?? 0).toInt(),
                  checkedInAt: _date(d.data()['checkedInAt']),
                ))
            .toList();
        list.sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));
        return list;
      });

  @override
  Future<CheckinRecord> checkIn(String userId, String pointId) => _guard(() async {
        final res = await _functions.httpsCallable('processQrCheckin').call<Map<String, dynamic>>({'pointId': pointId});
        final j = Map<String, dynamic>.from(res.data);
        return CheckinRecord(
          id: (j['recordId'] ?? '').toString(),
          pointId: pointId,
          pointName: (j['pointName'] ?? '').toString(),
          pointsEarned: (j['pointsEarned'] as num? ?? 0).toInt(),
          checkedInAt: DateTime.now(),
        );
      });

  @override
  Future<LoyaltySummary> fetchSummary(String userId) => _guard(() async {
        final doc = await _db.collection(FirestoreCollections.users).doc(userId).get();
        final loyalty = Map<String, dynamic>.from(doc.data()?['loyalty'] ?? const {});
        final available = (loyalty['availablePoints'] ?? doc.data()?['loyaltyPoints'] as num? ?? 0).toInt();
        final lifetime = (loyalty['lifetimePoints'] ?? doc.data()?['totalEarnedPoints'] as num? ?? 0).toInt();
        return LoyaltySummary(
          availablePoints: available,
          lifetimePoints: lifetime,
        );
      });

  @override
  Future<List<Reward>> fetchRewards() => _guard(() async {
        final snap = await _db.collection(FirestoreCollections.rewards).where('isActive', isEqualTo: true).get();
        if (snap.docs.isEmpty) {
          return LoyaltySampleData.rewards;
        }
        return snap.docs.map((d) {
          final j = d.data();
          return Reward(
            id: d.id,
            title: (j['title'] ?? '').toString(),
            description: (j['description'] ?? '').toString(),
            pointsCost: (j['pointsCost'] as num? ?? 0).toInt(),
            image: (j['imageUrl'] ?? '').toString(),
            category: j['category'] == 'voucher' ? RewardCategory.voucher : RewardCategory.souvenir,
            stock: (j['stock'] as num? ?? 0).toInt(),
            partner: (j['partner'] ?? '').toString(),
            pickupLocation: (j['pickupLocation'] ?? '').toString(),
            terms: List<String>.from(j['terms'] ?? const []),
          );
        }).toList();
      });

  @override
  Future<Redemption> redeem(String userId, String rewardId) => _guard(() async {
        final res = await _functions.httpsCallable('redeemReward').call<Map<String, dynamic>>({'rewardId': rewardId});
        final j = Map<String, dynamic>.from(res.data);
        return Redemption(
          id: (j['redemptionId'] ?? '').toString(),
          rewardId: rewardId,
          rewardTitle: (j['rewardTitle'] ?? '').toString(),
          rewardImage: (j['rewardImage'] ?? '').toString(),
          pointsSpent: (j['pointsSpent'] as num? ?? 0).toInt(),
          code: (j['code'] ?? '').toString(),
          redeemedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          status: RedemptionStatus.ready,
          pickupLocation: (j['pickupLocation'] ?? '').toString(),
        );
      });

  @override
  Future<List<Redemption>> fetchRedemptions(String userId) => _guard(() async {
        final snap = await _db
            .collection(FirestoreCollections.rewardRedemptions)
            .where('userId', isEqualTo: userId)
            .get();
        final list = snap.docs.map((d) {
          final j = d.data();
          return Redemption(
            id: d.id,
            rewardId: (j['rewardId'] ?? '').toString(),
            rewardTitle: (j['rewardTitle'] ?? '').toString(),
            rewardImage: (j['rewardImage'] ?? '').toString(),
            pointsSpent: (j['pointsSpent'] as num? ?? 0).toInt(),
            code: (j['code'] ?? '').toString(),
            redeemedAt: _date(j['redeemedAt']),
            expiresAt: _date(j['expiresAt']),
            status: RedemptionStatus.values.firstWhere(
              (s) => s.name == j['status'],
              orElse: () => RedemptionStatus.ready,
            ),
            pickupLocation: (j['pickupLocation'] ?? '').toString(),
          );
        }).toList();
        list.sort((a, b) => b.redeemedAt.compareTo(a.redeemedAt));
        return list;
      });
}

/// Dữ liệu mẫu: 8 điểm check-in và 6 phần quà.
class LoyaltySampleData {
  LoyaltySampleData._();

  static const List<CheckinPoint> points = [
    CheckinPoint(
      id: 'cp_vong_giang',
      name: 'Vọng Giang Đài',
      area: 'Núi Thủy Sơn',
      description: 'Đài ngắm cảnh cao nhất nhìn ra sông Cổ Cò và biển Đông.',
      points: 50,
      image: AppImages.marbleMountains,
      destinationId: 'ngu_hanh_son',
    ),
    CheckinPoint(
      id: 'cp_huyen_khong',
      name: 'Động Huyền Không',
      area: 'Núi Thủy Sơn',
      description: 'Bảng QR đặt tại cửa động, bên phải lối vào.',
      points: 50,
      image: AppImages.huyenKhongCave,
      destinationId: 'dong_huyen_khong',
    ),
    CheckinPoint(
      id: 'cp_linh_ung',
      name: 'Chùa Linh Ứng Non Nước',
      area: 'Núi Thủy Sơn',
      description: 'Bảng QR cạnh nhà khách của chùa.',
      points: 40,
      image: AppImages.linhUngPagoda,
      destinationId: 'chua_linh_ung_non_nuoc',
    ),
    CheckinPoint(
      id: 'cp_tam_thai',
      name: 'Chùa Tam Thai',
      area: 'Núi Thủy Sơn',
      description: 'Bảng QR tại cổng tam quan chùa Tam Thai.',
      points: 40,
      image: AppImages.linhUngPagoda,
      destinationId: 'chua_tam_thai',
    ),
    CheckinPoint(
      id: 'cp_am_phu',
      name: 'Động Âm Phủ',
      area: 'Chân núi Thủy Sơn',
      description: 'Bảng QR tại quầy soát vé Động Âm Phủ.',
      points: 40,
      image: AppImages.huyenKhongPanorama,
      destinationId: 'dong_am_phu',
    ),
    CheckinPoint(
      id: 'cp_lang_da',
      name: 'Làng đá mỹ nghệ Non Nước',
      area: 'Hòa Hải',
      description: 'Bảng QR tại cổng làng, cạnh nhà trưng bày.',
      points: 40,
      image: AppImages.nonNuocVillage,
      destinationId: 'lang_da_non_nuoc',
    ),
    CheckinPoint(
      id: 'cp_son_thuy',
      name: 'Bãi biển Sơn Thủy',
      area: 'Khuê Mỹ',
      description: 'Bảng QR tại chòi cứu hộ số 3.',
      points: 30,
      image: AppImages.sonThuyBeach,
      destinationId: 'bai_bien_son_thuy',
    ),
    CheckinPoint(
      id: 'cp_an_thuong',
      name: 'Phố Tây An Thượng',
      area: 'Mỹ An',
      description: 'Bảng QR tại cổng chào khu phố An Thượng.',
      points: 30,
      image: AppImages.anThuongStreet,
      destinationId: 'pho_an_thuong',
    ),
  ];

  static const List<Reward> rewards = [
    Reward(
      id: 'rw_ve_thang_may',
      title: 'Vé thang máy núi Thủy Sơn',
      description: 'Một lượt đi thang máy lên núi Thủy Sơn, tiết kiệm sức để khám phá các hang động.',
      pointsCost: 150,
      image: AppImages.marbleMountains,
      category: RewardCategory.voucher,
      stock: 120,
      partner: 'Ban Quản lý Danh thắng Ngũ Hành Sơn',
      pickupLocation: 'Quầy vé thang máy núi Thủy Sơn',
      terms: ['Áp dụng 1 lượt lên', 'Hạn sử dụng 30 ngày kể từ ngày đổi'],
    ),
    Reward(
      id: 'rw_cafe_an_thuong',
      title: 'Voucher cà phê An Thượng 50.000đ',
      description: 'Thưởng thức cà phê muối hoặc nước ép tại quán đối tác trong khu phố An Thượng.',
      pointsCost: 250,
      image: AppImages.anThuongStreet,
      category: RewardCategory.voucher,
      stock: 60,
      partner: 'Cà phê Phố Biển An Thượng',
      pickupLocation: 'An Thượng 4, phường Mỹ An',
      terms: ['Không quy đổi thành tiền mặt', 'Không áp dụng cùng khuyến mãi khác'],
    ),
    Reward(
      id: 'rw_moc_khoa_da',
      title: 'Móc khóa đá cẩm thạch Ngũ Hành Sơn',
      description: 'Móc khóa khắc hình năm ngọn núi, chế tác thủ công tại Làng đá Non Nước.',
      pointsCost: 300,
      image: AppImages.nonNuocVillage,
      category: RewardCategory.souvenir,
      stock: 80,
      partner: 'Hợp tác xã Làng đá mỹ nghệ Non Nước',
      pickupLocation: 'Nhà trưng bày Làng đá Non Nước',
    ),
    Reward(
      id: 'rw_voucher_workshop',
      title: 'Giảm 20% Workshop điêu khắc đá',
      description: 'Ưu đãi cho workshop điêu khắc đá mini cùng nghệ nhân Làng đá Non Nước.',
      pointsCost: 400,
      image: AppImages.artisanWorkshop,
      category: RewardCategory.voucher,
      stock: 40,
      partner: 'Xưởng điêu khắc Non Nước',
      pickupLocation: 'Xuất trình mã khi check-in workshop',
      terms: ['Áp dụng cho tối đa 2 người/lượt đặt'],
    ),
    Reward(
      id: 'rw_vong_tay_da',
      title: 'Vòng tay đá ngũ hành',
      description: 'Vòng tay đá tự nhiên mài thủ công, chọn màu theo mệnh của bạn.',
      pointsCost: 600,
      image: AppImages.stoneLotusStatue,
      category: RewardCategory.souvenir,
      stock: 25,
      partner: 'Xưởng trang sức đá Mai Non Nước',
      pickupLocation: 'Xưởng trang sức đá Mai, Làng đá Non Nước',
    ),
    Reward(
      id: 'rw_tuong_da_mini',
      title: 'Tượng đá mini Rồng cuộn mây',
      description: 'Tượng đá cẩm thạch trắng cao 12 cm – món quà lưu niệm đặc trưng của Ngũ Hành Sơn.',
      pointsCost: 900,
      image: AppImages.stoneDragonCarving,
      category: RewardCategory.souvenir,
      stock: 0,
      partner: 'Hợp tác xã Làng đá mỹ nghệ Non Nước',
      pickupLocation: 'Nhà trưng bày Làng đá Non Nước',
      terms: ['Số lượng có hạn – sẽ bổ sung vào đầu tháng'],
    ),
  ];
}
