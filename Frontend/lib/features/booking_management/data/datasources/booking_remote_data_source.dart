import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/booking_entities.dart';

/// Ánh xạ Firestore ↔ Booking.
class BookingModel {
  BookingModel._();

  static Booking fromFirestore(Map<String, dynamic> j, String id) {
    DateTime date(dynamic v) => v is Timestamp ? v.toDate() : DateTime.tryParse('$v') ?? DateTime.now();
    return Booking(
      id: id,
      code: (j['code'] ?? id).toString(),
      userId: (j['userId'] ?? '').toString(),
      serviceId: (j['serviceId'] ?? '').toString(),
      serviceTitle: (j['serviceTitle'] ?? '').toString(),
      serviceImage: (j['serviceImage'] ?? '').toString(),
      venue: (j['venue'] ?? '').toString(),
      sessionAt: date(j['sessionAt']),
      participants: (j['participants'] as num? ?? 1).toInt(),
      unitPrice: (j['unitPrice'] as num? ?? 0).toInt(),
      status: BookingStatus.fromName(j['status']?.toString()),
      contactName: (j['contactName'] ?? '').toString(),
      contactPhone: (j['contactPhone'] ?? '').toString(),
      createdAt: date(j['createdAt']),
      note: (j['note'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> toFirestore(Booking b) => {
        'code': b.code,
        'userId': b.userId,
        'serviceId': b.serviceId,
        'serviceTitle': b.serviceTitle,
        'serviceImage': b.serviceImage,
        'venue': b.venue,
        'sessionAt': Timestamp.fromDate(b.sessionAt),
        'participants': b.participants,
        'unitPrice': b.unitPrice,
        'totalPrice': b.totalPrice,
        'status': b.status.name,
        'contactName': b.contactName,
        'contactPhone': b.contactPhone,
        'note': b.note,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

String generateBookingCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final r = Random();
  return 'ST-${List.generate(6, (_) => chars[r.nextInt(chars.length)]).join()}';
}

/// [FE-07] Nguồn dữ liệu đặt chỗ.
abstract class BookingRemoteDataSource {
  Future<Booking> create(Booking booking);
  Future<List<Booking>> fetchByUser(String userId);
  Future<Booking> fetchById(String id);
  Future<Booking> updateStatus(String id, BookingStatus status);
}

class MockBookingRemoteDataSource implements BookingRemoteDataSource {
  MockBookingRemoteDataSource() {
    final now = DateTime.now();
    for (final b in [
      Booking(
        id: 'bk_demo_01',
        code: 'ST-7K2M9Q',
        userId: 'demo-tourist-001',
        serviceId: 'svc_tour_thuyet_minh',
        serviceTitle: 'Tour thuyết minh Ngũ Hành Sơn cùng hướng dẫn viên',
        serviceImage: AppImages.marbleMountains,
        venue: 'Cổng chính Danh thắng Ngũ Hành Sơn',
        sessionAt: DateTime(now.year, now.month, now.day - 12, 8),
        participants: 2,
        unitPrice: 150000,
        status: BookingStatus.completed,
        contactName: 'Nguyễn Minh Anh',
        contactPhone: '0905123456',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Booking(
        id: 'bk_demo_02',
        code: 'ST-4HX8PZ',
        userId: 'demo-tourist-001',
        serviceId: 'ws_am_thuc_an_thuong',
        serviceTitle: 'Lớp nấu Mì Quảng & Bánh xèo xứ Quảng',
        serviceImage: AppImages.anThuongStreet,
        venue: 'Bếp nhà Quảng – An Thượng',
        sessionAt: DateTime(now.year, now.month, now.day + 2, 9),
        participants: 2,
        unitPrice: 350000,
        status: BookingStatus.confirmed,
        contactName: 'Nguyễn Minh Anh',
        contactPhone: '0905123456',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]) {
      _store[b.id] = b;
    }
  }

  final Map<String, Booking> _store = {};

  @override
  Future<Booking> create(Booking booking) async {
    await simulateLatency();
    final saved = booking.copyWith(status: BookingStatus.confirmed);
    _store[saved.id] = saved;
    return saved;
  }

  @override
  Future<List<Booking>> fetchByUser(String userId) async {
    await simulateLatency();
    return _store.values.where((b) => b.userId == userId).toList();
  }

  @override
  Future<Booking> fetchById(String id) async {
    await simulateLatency();
    final b = _store[id];
    if (b == null) throw const ServerException('Không tìm thấy đơn đặt chỗ.');
    return b;
  }

  @override
  Future<Booking> updateStatus(String id, BookingStatus status) async {
    await simulateLatency();
    final b = _store[id];
    if (b == null) throw const ServerException('Không tìm thấy đơn đặt chỗ.');
    return _store[id] = b.copyWith(status: status);
  }
}

class FirestoreBookingRemoteDataSource implements BookingRemoteDataSource {
  FirestoreBookingRemoteDataSource([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection(FirestoreCollections.bookings);

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Không kết nối được máy chủ.', code: e.code);
    }
  }

  @override
  Future<Booking> create(Booking booking) => _guard(() async {
        // Trạng thái "pending" – Cloud Function kiểm tra sức chứa rồi chuyển sang "confirmed".
        final ref = await _col.add(BookingModel.toFirestore(booking));
        final doc = await ref.get();
        return BookingModel.fromFirestore(doc.data()!, doc.id);
      });

  @override
  Future<List<Booking>> fetchByUser(String userId) => _guard(() async {
        final snap = await _col.where('userId', isEqualTo: userId).get();
        final list = snap.docs.map((d) => BookingModel.fromFirestore(d.data(), d.id)).toList();
        list.sort((a, b) => b.sessionAt.compareTo(a.sessionAt));
        return list;
      });

  @override
  Future<Booking> fetchById(String id) => _guard(() async {
        final doc = await _col.doc(id).get();
        if (!doc.exists) throw const ServerException('Không tìm thấy đơn đặt chỗ.');
        return BookingModel.fromFirestore(doc.data()!, doc.id);
      });

  @override
  Future<Booking> updateStatus(String id, BookingStatus status) => _guard(() async {
        await _col.doc(id).update({'status': status.name, 'updatedAt': FieldValue.serverTimestamp()});
        return fetchById(id);
      });
}

/// Các dịch vụ đặt chỗ độc lập (ngoài sự kiện/workshop).
class StandaloneServiceSampleData {
  StandaloneServiceSampleData._();

  static List<BookableService> services() {
    final now = DateTime.now();
    List<DateTime> slots(List<(int, int)> times) => [
          for (var d = 1; d <= 3; d++)
            for (final t in times) DateTime(now.year, now.month, now.day + d, t.$1, t.$2),
        ];
    return [
      BookableService(
        id: 'svc_tour_thuyet_minh',
        title: 'Tour thuyết minh Ngũ Hành Sơn cùng hướng dẫn viên',
        typeLabel: 'Dịch vụ tham quan',
        price: 150000,
        coverImage: AppImages.marbleMountains,
        venue: 'Cổng chính Danh thắng Ngũ Hành Sơn',
        sessions: slots([(8, 0), (9, 30), (14, 0), (15, 30)]),
        remainingSlots: 20,
        durationLabel: '2 giờ',
        maxPerBooking: 15,
      ),
      BookableService(
        id: 'svc_thue_sup',
        title: 'Thuê ván SUP & kayak biển Sơn Thủy',
        typeLabel: 'Dịch vụ biển',
        price: 120000,
        coverImage: AppImages.sonThuyBeach,
        venue: 'Chòi dịch vụ số 3, bãi biển Sơn Thủy',
        sessions: slots([(6, 0), (7, 30), (16, 0)]),
        remainingSlots: 12,
        durationLabel: '1 giờ',
        maxPerBooking: 6,
      ),
      BookableService(
        id: 'svc_xe_dien',
        title: 'Xe điện tham quan Ngũ Hành Sơn – Làng đá Non Nước',
        typeLabel: 'Di chuyển',
        price: 50000,
        coverImage: AppImages.nonNuocVillage,
        venue: 'Bãi xe phía Nam núi Thủy Sơn',
        sessions: slots([(8, 0), (10, 0), (13, 30), (15, 30)]),
        remainingSlots: 30,
        durationLabel: '45 phút',
      ),
    ];
  }
}
