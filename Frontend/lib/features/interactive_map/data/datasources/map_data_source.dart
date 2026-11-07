import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/map_poi.dart';

/// Model POI – ánh xạ từ tài liệu Firestore (`destinations`, `events_workshops`,
/// `checkin_points`) có trường `location` (GeoPoint) và `mapLayer`.
class MapPoiModel extends MapPoi {
  const MapPoiModel({
    required super.id,
    required super.name,
    required super.layer,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.description,
    super.openingHours,
    super.rating,
    super.priceHint,
    super.image,
    super.destinationId,
    super.eventId,
  });

  factory MapPoiModel.fromFirestore(Map<String, dynamic> json, String id, {MapLayer? layer}) {
    final location = json['location'];
    double lat = 0, lng = 0;
    if (location is GeoPoint) {
      lat = location.latitude;
      lng = location.longitude;
    } else if (location is Map) {
      final geo = location['geopoint'];
      if (geo is GeoPoint) {
        lat = geo.latitude;
        lng = geo.longitude;
      }
    }
    final name = json['name'];
    return MapPoiModel(
      id: id,
      name: name is Map ? (name['vi'] ?? '').toString() : (name ?? json['title'] ?? '').toString(),
      layer: layer ?? MapLayer.fromCode((json['mapLayer'] ?? 'attraction').toString()),
      latitude: lat,
      longitude: lng,
      address: (json['address'] ?? '').toString(),
      description: (json['shortDescription'] ?? json['description'] ?? '').toString(),
      openingHours: json['openingHours']?.toString(),
      rating: (json['ratingAvg'] as num?)?.toDouble(),
      image: json['coverImageUrl']?.toString(),
      destinationId: layer == MapLayer.attraction ? id : json['destinationId']?.toString(),
    );
  }
}

abstract class MapRemoteDataSource {
  Future<List<MapPoiModel>> fetchPois();
}

class MockMapRemoteDataSource implements MapRemoteDataSource {
  @override
  Future<List<MapPoiModel>> fetchPois() async {
    await simulateLatency();
    return MapSampleData.pois;
  }
}

class FirestoreMapRemoteDataSource implements MapRemoteDataSource {
  FirestoreMapRemoteDataSource([FirebaseFirestore? firestore]) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Future<List<MapPoiModel>> fetchPois() async {
    try {
      final results = await Future.wait([
        _db.collection(FirestoreCollections.destinations).where('isPublished', isEqualTo: true).get(),
        _db.collection(FirestoreCollections.eventsWorkshops).where('status', isEqualTo: 'published').get(),
        _db.collection(FirestoreCollections.checkinPoints).where('isActive', isEqualTo: true).get(),
      ]);
      final combined = [
        ...results[0].docs.map((d) => MapPoiModel.fromFirestore(d.data(), d.id)),
        ...results[1].docs.map((d) => MapPoiModel.fromFirestore(d.data(), d.id, layer: MapLayer.workshopEvent)),
        ...results[2].docs.map((d) => MapPoiModel.fromFirestore(d.data(), d.id, layer: MapLayer.qrCheckin)),
      ];
      if (combined.isEmpty) {
        return MapSampleData.pois;
      }
      return combined;
    } on FirebaseException catch (_) {
      return MapSampleData.pois;
    }
  }
}

/// Dữ liệu mẫu các điểm trên bản đồ quận Ngũ Hành Sơn (tọa độ gần đúng).
class MapSampleData {
  MapSampleData._();

  static const List<MapPoiModel> pois = [
    // ── Điểm tham quan
    MapPoiModel(
      id: 'poi_ngu_hanh_son',
      name: 'Danh thắng Ngũ Hành Sơn',
      layer: MapLayer.attraction,
      latitude: 16.0036,
      longitude: 108.2638,
      address: '81 Huyền Trân Công Chúa, Hòa Hải',
      description: 'Quần thể 5 ngọn núi đá vôi – Di tích quốc gia đặc biệt.',
      openingHours: '07:00 – 17:30',
      rating: 4.8,
      priceHint: 'Vé 40.000đ',
      image: AppImages.marbleMountains,
      destinationId: 'ngu_hanh_son',
    ),
    MapPoiModel(
      id: 'poi_huyen_khong',
      name: 'Động Huyền Không',
      layer: MapLayer.attraction,
      latitude: 16.0042,
      longitude: 108.2627,
      address: 'Núi Thủy Sơn',
      description: 'Hang động có cột nắng tự nhiên đẹp nhất vào 9 – 11 giờ sáng.',
      openingHours: '07:00 – 17:30',
      rating: 4.9,
      image: AppImages.huyenKhongCave,
      destinationId: 'dong_huyen_khong',
    ),
    MapPoiModel(
      id: 'poi_linh_ung',
      name: 'Chùa Linh Ứng Non Nước',
      layer: MapLayer.attraction,
      latitude: 16.0048,
      longitude: 108.2646,
      address: 'Đỉnh núi Thủy Sơn',
      description: 'Ngôi chùa cổ trên núi Thủy Sơn, nhìn ra biển Non Nước.',
      openingHours: '06:00 – 18:00',
      rating: 4.8,
      image: AppImages.linhUngPagoda,
      destinationId: 'chua_linh_ung_non_nuoc',
    ),
    MapPoiModel(
      id: 'poi_am_phu',
      name: 'Động Âm Phủ',
      layer: MapLayer.attraction,
      latitude: 16.0021,
      longitude: 108.2618,
      address: 'Chân núi Thủy Sơn (phía Tây)',
      description: 'Hang động gắn với truyền thuyết cõi âm, có cầu Âm Dương.',
      openingHours: '07:00 – 17:30',
      rating: 4.5,
      destinationId: 'dong_am_phu',
    ),
    // ── Nhà hàng & dịch vụ
    MapPoiModel(
      id: 'poi_mi_quang_ba_mua',
      name: 'Quán Mì Quảng Non Nước',
      layer: MapLayer.dining,
      latitude: 16.0012,
      longitude: 108.2655,
      address: 'Đường Huyền Trân Công Chúa',
      description: 'Mì Quảng tôm thịt, bánh tráng cuốn thịt heo kiểu xứ Quảng.',
      openingHours: '06:30 – 20:00',
      rating: 4.6,
      priceHint: '35.000 – 60.000đ',
    ),
    MapPoiModel(
      id: 'poi_hai_san_son_thuy',
      name: 'Nhà hàng Hải sản Sơn Thủy',
      layer: MapLayer.dining,
      latitude: 16.0262,
      longitude: 108.2548,
      address: 'Đường Võ Nguyên Giáp, Khuê Mỹ',
      description: 'Hải sản tươi sống bên bờ biển, view hoàng hôn.',
      openingHours: '10:00 – 22:30',
      rating: 4.4,
      priceHint: '150.000 – 400.000đ',
    ),
    MapPoiModel(
      id: 'poi_thong_tin_du_lich',
      name: 'Trung tâm Thông tin Du lịch',
      layer: MapLayer.dining,
      latitude: 16.0030,
      longitude: 108.2650,
      address: 'Cổng chính Danh thắng Ngũ Hành Sơn',
      description: 'Hỗ trợ du khách, cho thuê thuyết minh, gửi đồ và nhà vệ sinh.',
      openingHours: '07:00 – 17:30',
    ),
    MapPoiModel(
      id: 'poi_cafe_view_nui',
      name: 'Cà phê View Núi',
      layer: MapLayer.dining,
      latitude: 16.0058,
      longitude: 108.2612,
      address: 'Đường Lê Văn Hiến',
      description: 'Quán cà phê sân vườn nhìn thẳng ra núi Thủy Sơn.',
      openingHours: '06:00 – 22:00',
      rating: 4.5,
      priceHint: '30.000 – 55.000đ',
    ),
    // ── Bãi biển
    MapPoiModel(
      id: 'poi_bien_son_thuy',
      name: 'Bãi biển Sơn Thủy',
      layer: MapLayer.beach,
      latitude: 16.0315,
      longitude: 108.2530,
      address: 'Đường Võ Nguyên Giáp, Khuê Mỹ',
      description: 'Bãi tắm công cộng có cứu hộ, cát trắng mịn, nước trong.',
      openingHours: 'Cứu hộ: 05:00 – 18:00',
      rating: 4.7,
      image: AppImages.sonThuyBeach,
      destinationId: 'bai_bien_son_thuy',
    ),
    MapPoiModel(
      id: 'poi_bien_tan_tra',
      name: 'Bãi biển Tân Trà',
      layer: MapLayer.beach,
      latitude: 16.0150,
      longitude: 108.2600,
      address: 'Đường Trường Sa, Hòa Hải',
      description: 'Bãi biển hoang sơ, yên tĩnh, thích hợp ngắm bình minh.',
      rating: 4.6,
    ),
    MapPoiModel(
      id: 'poi_bien_non_nuoc',
      name: 'Bãi biển Non Nước',
      layer: MapLayer.beach,
      latitude: 15.9990,
      longitude: 108.2705,
      address: 'Đường Trường Sa, Hòa Hải',
      description: 'Bãi biển dài, sóng êm, gần Danh thắng Ngũ Hành Sơn.',
      openingHours: 'Cứu hộ: 05:00 – 18:00',
      rating: 4.6,
      destinationId: 'bai_bien_non_nuoc',
    ),
    // ── Khu An Thượng
    MapPoiModel(
      id: 'poi_pho_an_thuong',
      name: 'Phố Tây An Thượng',
      layer: MapLayer.anThuong,
      latitude: 16.0478,
      longitude: 108.2460,
      address: 'Khu phố An Thượng, Mỹ An',
      description: 'Khu phố sôi động với ẩm thực quốc tế, quán bar và cà phê.',
      openingHours: 'Sôi động nhất từ 18:00',
      rating: 4.5,
      image: AppImages.anThuongStreet,
      destinationId: 'pho_an_thuong',
    ),
    MapPoiModel(
      id: 'poi_an_thuong_night_bar',
      name: 'Rooftop Bar An Thượng',
      layer: MapLayer.anThuong,
      latitude: 16.0486,
      longitude: 108.2448,
      address: 'An Thượng 4, Mỹ An',
      description: 'Nhạc sống mỗi tối, cocktail và tầm nhìn ra biển Mỹ Khê.',
      openingHours: '17:00 – 01:00',
      rating: 4.4,
      priceHint: '80.000 – 200.000đ',
    ),
    MapPoiModel(
      id: 'poi_an_thuong_banh_mi',
      name: 'Bánh mì & Street Food An Thượng',
      layer: MapLayer.anThuong,
      latitude: 16.0470,
      longitude: 108.2472,
      address: 'An Thượng 2, Mỹ An',
      description: 'Bánh mì, bánh xèo và các món ăn đường phố được du khách yêu thích.',
      openingHours: '07:00 – 23:00',
      rating: 4.6,
      priceHint: '25.000 – 70.000đ',
    ),
    // ── Workshop & sự kiện
    MapPoiModel(
      id: 'poi_ws_dieu_khac',
      name: 'Workshop Điêu khắc đá mini',
      layer: MapLayer.workshopEvent,
      latitude: 16.0005,
      longitude: 108.2632,
      address: 'Làng đá mỹ nghệ Non Nước',
      description: 'Tự tay chạm khắc móc khóa đá cẩm thạch cùng nghệ nhân.',
      openingHours: '08:00 – 16:30',
      rating: 4.9,
      priceHint: '250.000đ/người',
      image: AppImages.nonNuocVillage,
      eventId: 'ws_dieu_khac_da',
    ),
    MapPoiModel(
      id: 'poi_ev_dem_nhac_bien',
      name: 'Đêm nhạc biển Sơn Thủy',
      layer: MapLayer.workshopEvent,
      latitude: 16.0300,
      longitude: 108.2538,
      address: 'Quảng trường biển Sơn Thủy',
      description: 'Chương trình âm nhạc ngoài trời mỗi tối thứ Bảy mùa hè.',
      openingHours: '19:30 – 22:00',
      eventId: 'ev_dem_nhac_bien',
    ),
    // ── QR check-in
    MapPoiModel(
      id: 'poi_qr_vong_giang',
      name: 'QR Check-in Vọng Giang Đài',
      layer: MapLayer.qrCheckin,
      latitude: 16.0051,
      longitude: 108.2640,
      address: 'Đỉnh Thủy Sơn',
      description: 'Quét mã QR tại bảng thông tin để nhận 50 điểm thưởng.',
    ),
    MapPoiModel(
      id: 'poi_qr_huyen_khong',
      name: 'QR Check-in Động Huyền Không',
      layer: MapLayer.qrCheckin,
      latitude: 16.0044,
      longitude: 108.2624,
      address: 'Cửa động Huyền Không',
      description: 'Quét mã QR tại cửa động để nhận 50 điểm thưởng.',
    ),
    MapPoiModel(
      id: 'poi_qr_lang_da',
      name: 'QR Check-in Làng đá Non Nước',
      layer: MapLayer.qrCheckin,
      latitude: 16.0000,
      longitude: 108.2640,
      address: 'Cổng làng đá mỹ nghệ Non Nước',
      description: 'Quét mã QR tại cổng làng để nhận 40 điểm thưởng.',
    ),
    MapPoiModel(
      id: 'poi_qr_son_thuy',
      name: 'QR Check-in Biển Sơn Thủy',
      layer: MapLayer.qrCheckin,
      latitude: 16.0322,
      longitude: 108.2526,
      address: 'Chòi cứu hộ số 3, Sơn Thủy',
      description: 'Quét mã QR tại chòi cứu hộ để nhận 30 điểm thưởng.',
    ),
  ];
}
