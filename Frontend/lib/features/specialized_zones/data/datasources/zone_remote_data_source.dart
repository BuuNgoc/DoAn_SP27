import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/zone_entities.dart';

abstract class ZoneRemoteDataSource {
  Future<ZoneOverview> getZoneOverview(ZoneType zone);
  Future<AirportWelcomeContent> getAirportWelcome({String? campaignId});
}

class MockZoneRemoteDataSource implements ZoneRemoteDataSource {
  @override
  Future<ZoneOverview> getZoneOverview(ZoneType zone) async {
    await simulateLatency();
    return zone == ZoneType.anThuong ? ZoneSampleData.anThuong() : ZoneSampleData.beach();
  }

  @override
  Future<AirportWelcomeContent> getAirportWelcome({String? campaignId}) async {
    await simulateLatency(const Duration(milliseconds: 300));
    return ZoneSampleData.airport(campaignId);
  }
}

/// Bản Firebase: nội dung biên tập (giới thiệu, địa điểm) dùng dữ liệu nền;
/// thông tin an toàn bãi biển và chiến dịch sân bay đọc trực tiếp từ Firestore
/// để Ban quản lý cập nhật theo thời gian thực.
class FirestoreZoneRemoteDataSource implements ZoneRemoteDataSource {
  FirestoreZoneRemoteDataSource([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  @override
  Future<ZoneOverview> getZoneOverview(ZoneType zone) async {
    if (zone == ZoneType.anThuong) return ZoneSampleData.anThuong();
    final base = ZoneSampleData.beach();
    try {
      final doc = await _db.collection(FirestoreCollections.destinations).doc('bai_bien_son_thuy').get();
      final m = doc.data()?['beachSafety'] as Map<String, dynamic>?;
      if (m == null) return base;
      final level = SafetyLevel.values.firstWhere((l) => l.name == m['level'], orElse: () => SafetyLevel.safe);
      final s = base.safety!;
      return ZoneOverview(
        zone: base.zone,
        title: base.title,
        tagline: base.tagline,
        introduction: base.introduction,
        heroImage: base.heroImage,
        spots: base.spots,
        relatedEventIds: base.relatedEventIds,
        tips: base.tips,
        beaches: base.beaches,
        safety: BeachSafetyInfo(
          overallLevel: level,
          waveHeight: (m['waveHeight'] as String?) ?? s.waveHeight,
          windSpeed: (m['windSpeed'] as String?) ?? s.windSpeed,
          waterTemperature: (m['waterTemperature'] as String?) ?? s.waterTemperature,
          uvIndex: (m['uvIndex'] as String?) ?? s.uvIndex,
          updatedAt: (m['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          headline: (m['headline'] as String?) ?? s.headline,
          tips: s.tips,
          contacts: s.contacts,
        ),
      );
    } on FirebaseException {
      return base;
    }
  }

  @override
  Future<AirportWelcomeContent> getAirportWelcome({String? campaignId}) async {
    final base = ZoneSampleData.airport(campaignId);
    if (campaignId == null) return base;
    try {
      final doc = await _db.collection(FirestoreCollections.promotionCampaigns).doc(campaignId).get();
      final m = doc.data();
      if (m == null) return base;
      return AirportWelcomeContent(
        campaignId: campaignId,
        headline: (m['headline'] as String?) ?? base.headline,
        message: (m['message'] as String?) ?? base.message,
        heroImage: base.heroImage,
        distanceFromAirport: base.distanceFromAirport,
        travelOptions: base.travelOptions,
        quickFacts: base.quickFacts,
        featuredDestinationIds: List<String>.from((m['destinationIds'] as List?) ?? base.featuredDestinationIds),
        featuredEventIds: List<String>.from((m['eventIds'] as List?) ?? base.featuredEventIds),
        welcomeOffer: (m['offer'] as String?) ?? base.welcomeOffer,
      );
    } on FirebaseException {
      return base;
    }
  }
}

/// Dữ liệu mẫu phân khu. Tên cơ sở kinh doanh mang tính minh họa cho bản demo.
class ZoneSampleData {
  ZoneSampleData._();

  static ZoneOverview anThuong() => const ZoneOverview(
        zone: ZoneType.anThuong,
        title: 'Phố Tây An Thượng',
        tagline: 'Ẩm thực đa quốc gia · Cà phê · Nightlife',
        introduction:
            'Nằm giữa biển Mỹ Khê và núi Ngũ Hành Sơn, khu phố An Thượng (phường Mỹ An) là nơi giao thoa văn hóa '
            'với hàng trăm nhà hàng, quán cà phê, quán bar và homestay. Phố sôi động nhất từ 18:00 đến khuya, '
            'đặc biệt vào cuối tuần với nhạc sống và các phiên chợ đêm ẩm thực.',
        heroImage: AppImages.anThuongStreet,
        relatedEventIds: ['ws_am_thuc_an_thuong', 'ev_le_hoi_am_thuc_an_thuong'],
        tips: [
          'Khu phố chủ yếu là đường nhỏ một chiều – nên đi bộ hoặc xe đạp sau 18:00.',
          'Nhiều quán nhận thanh toán thẻ và ví điện tử; hãy hỏi giá trước với món hải sản tươi.',
          'Giữ trật tự sau 22:00 để tôn trọng cư dân địa phương.',
        ],
        spots: [
          ZoneSpot(
            id: 'at_mi_quang_ba_mua',
            zone: ZoneType.anThuong,
            name: 'Quán Mì Quảng Cô Ba',
            category: ZoneSpotCategory.food,
            description: 'Mì Quảng tôm thịt, gà ta nấu theo công thức gia truyền Điện Bàn, ăn kèm bánh tráng mè nướng.',
            image: AppImages.anThuongStreet,
            address: 'An Thượng 4, phường Mỹ An',
            openingHours: '06:30 – 21:00',
            priceRange: '35.000 – 60.000đ',
            latitude: 16.0512,
            longitude: 108.2449,
            rating: 4.6,
            tags: ['Món Quảng', 'Bình dân'],
          ),
          ZoneSpot(
            id: 'at_hai_san_bien_xanh',
            zone: ZoneType.anThuong,
            name: 'Nhà hàng Hải sản Biển Xanh',
            category: ZoneSpotCategory.food,
            description: 'Hải sản tươi chọn tại bể: tôm hùm, cua, mực một nắng, ốc hương rang muối ớt.',
            image: AppImages.sonThuyBeach,
            address: 'An Thượng 2, phường Mỹ An',
            openingHours: '10:00 – 23:00',
            priceRange: '150.000 – 500.000đ',
            latitude: 16.0498,
            longitude: 108.2462,
            rating: 4.4,
            tags: ['Hải sản', 'Nhóm đông'],
          ),
          ZoneSpot(
            id: 'at_banh_xeo',
            zone: ZoneType.anThuong,
            name: 'Bánh xèo – Nem lụi Mỹ An',
            category: ZoneSpotCategory.food,
            description: 'Bánh xèo giòn rụm, nem lụi nướng than hoa, chấm nước lèo gan heo đậu phộng đặc trưng Đà Nẵng.',
            image: AppImages.anThuongStreet,
            address: 'An Thượng 18, phường Mỹ An',
            openingHours: '15:00 – 22:00',
            priceRange: '40.000 – 90.000đ',
            latitude: 16.0521,
            longitude: 108.2441,
            rating: 4.5,
            tags: ['Đặc sản', 'Ăn tối'],
          ),
          ZoneSpot(
            id: 'at_cafe_soi_da',
            zone: ZoneType.anThuong,
            name: 'Sỏi Đá Coffee & Workspace',
            category: ZoneSpotCategory.cafe,
            description: 'Không gian tối giản, trang trí bằng đá Non Nước; cà phê muối, bạc xỉu và wifi tốc độ cao.',
            image: AppImages.nonNuocVillage,
            address: 'An Thượng 26, phường Mỹ An',
            openingHours: '07:00 – 22:30',
            priceRange: '35.000 – 70.000đ',
            latitude: 16.0503,
            longitude: 108.2437,
            rating: 4.7,
            tags: ['Làm việc', 'Yên tĩnh'],
          ),
          ZoneSpot(
            id: 'at_rooftop_sunset',
            zone: ZoneType.anThuong,
            name: 'Sunset Rooftop Bar',
            category: ZoneSpotCategory.nightlife,
            description: 'Sân thượng ngắm hoàng hôn hướng núi Ngũ Hành Sơn, cocktail và DJ từ 20:00 tối thứ Sáu – Chủ Nhật.',
            image: AppImages.anThuongStreet,
            address: 'Đường Lê Quang Đạo, phường Mỹ An',
            openingHours: '16:00 – 01:00',
            priceRange: '90.000 – 250.000đ',
            latitude: 16.0489,
            longitude: 108.2471,
            rating: 4.5,
            tags: ['Hoàng hôn', 'DJ cuối tuần'],
          ),
          ZoneSpot(
            id: 'at_live_music',
            zone: ZoneType.anThuong,
            name: 'Acoustic Corner',
            category: ZoneSpotCategory.nightlife,
            description: 'Quán nhạc sống acoustic mỗi tối, có đêm nhạc Trịnh vào thứ Tư và open mic vào thứ Bảy.',
            image: AppImages.anThuongStreet,
            address: 'An Thượng 1, phường Mỹ An',
            openingHours: '18:30 – 23:30',
            priceRange: '50.000 – 120.000đ',
            latitude: 16.0516,
            longitude: 108.2458,
            rating: 4.3,
            tags: ['Nhạc sống', 'Lãng mạn'],
          ),
        ],
      );

  static ZoneOverview beach() => ZoneOverview(
        zone: ZoneType.beach,
        title: 'Biển Sơn Thủy – Tân Trà – Non Nước',
        tagline: 'Cát trắng, nước trong · Thể thao biển · Cứu hộ chuyên nghiệp',
        introduction:
            'Dải bờ biển dài hơn 5 km chạy dọc quận Ngũ Hành Sơn, nối từ bãi Sơn Thủy qua Non Nước đến Tân Trà. '
            'Nước biển trong xanh, sóng êm từ tháng 3 đến tháng 9, lý tưởng cho tắm biển, chèo SUP, lướt ván '
            'và dạo bộ ngắm bình minh với núi Ngũ Hành Sơn phía sau.',
        heroImage: AppImages.sonThuyBeach,
        relatedEventIds: const ['ws_yoga_binh_minh', 'ev_dem_nhac_bien'],
        tips: const [
          'Thời điểm tắm biển lý tưởng: 05:00 – 08:30 và 16:00 – 18:00.',
          'Thoa kem chống nắng SPF 50+ và uống đủ nước; chỉ số UV buổi trưa thường rất cao.',
          'Không để lại rác trên bãi cát – hãy dùng thùng rác phân loại dọc lối xuống biển.',
        ],
        beaches: const [
          BeachArea(
            id: 'beach_son_thuy',
            name: 'Bãi tắm Sơn Thủy',
            description: 'Bãi tắm công cộng sạch đẹp, có chòi cứu hộ, khu tắm nước ngọt và bãi giữ xe rộng.',
            image: AppImages.sonThuyBeach,
            lifeguardHours: '05:00 – 18:30',
            facilities: ['Chòi cứu hộ', 'Tắm nước ngọt', 'Thuê ghế dù', 'Giữ xe'],
            safetyLevel: SafetyLevel.safe,
            destinationId: 'bai_bien_son_thuy',
          ),
          BeachArea(
            id: 'beach_non_nuoc',
            name: 'Bãi tắm Non Nước',
            description: 'Bãi cát trắng mịn yên tĩnh dưới chân Ngũ Hành Sơn, thích hợp nghỉ dưỡng và dạo bộ.',
            image: AppImages.sonThuyPanorama,
            lifeguardHours: '05:00 – 18:00',
            facilities: ['Chòi cứu hộ', 'Nhà vệ sinh', 'Quầy nước'],
            safetyLevel: SafetyLevel.safe,
            destinationId: 'bai_bien_non_nuoc',
          ),
          BeachArea(
            id: 'beach_tan_tra',
            name: 'Bãi tắm Tân Trà',
            description: 'Bãi biển hoang sơ giáp Hội An; sóng có thể mạnh hơn vào buổi chiều, cần chú ý cờ hiệu.',
            image: AppImages.sonThuyBeach,
            lifeguardHours: '05:30 – 17:30',
            facilities: ['Chòi cứu hộ', 'Cho thuê SUP'],
            safetyLevel: SafetyLevel.caution,
          ),
        ],
        safety: BeachSafetyInfo(
          overallLevel: SafetyLevel.safe,
          waveHeight: '0,5 – 1,0 m',
          windSpeed: 'Cấp 3 (12 – 19 km/h)',
          waterTemperature: '27°C',
          uvIndex: '9 – Rất cao',
          updatedAt: DateTime.now().subtract(const Duration(minutes: 40)),
          headline: 'Biển êm, có thể tắm trong khu vực cắm cờ của lực lượng cứu hộ.',
          tips: const [
            'Chỉ tắm trong khu vực có cờ và chòi cứu hộ, trong khung giờ cứu hộ trực.',
            'Không tắm biển khi say rượu bia, khi no hoặc lúc trời tối.',
            'Nếu bị dòng rip cuốn ra xa: bình tĩnh, bơi song song với bờ rồi mới bơi vào.',
            'Trẻ em phải có người lớn giám sát và mặc áo phao.',
            'Cờ đỏ: tuyệt đối không xuống nước; tuân thủ hướng dẫn của nhân viên cứu hộ.',
          ],
          contacts: const [
            EmergencyContact('Cứu nạn, cứu hộ', '112', Icons.support_rounded),
            EmergencyContact('Cấp cứu y tế', '115', Icons.local_hospital_rounded),
            EmergencyContact('Công an', '113', Icons.local_police_rounded),
            EmergencyContact('Cứu hỏa', '114', Icons.local_fire_department_rounded),
          ],
        ),
        spots: const [
          ZoneSpot(
            id: 'bc_sup',
            zone: ZoneType.beach,
            name: 'Chèo ván đứng SUP',
            category: ZoneSpotCategory.beachActivity,
            description: 'Thuê ván SUP kèm áo phao và hướng dẫn cơ bản; đẹp nhất lúc bình minh khi biển lặng.',
            image: AppImages.sonThuyBeach,
            address: 'Bãi tắm Sơn Thủy',
            openingHours: '05:00 – 10:00 · 15:00 – 18:00',
            priceRange: '150.000đ/giờ',
            latitude: 16.0128,
            longitude: 108.2668,
            rating: 4.7,
            tags: ['Người mới', 'Bình minh'],
            bookableServiceId: 'svc_thue_sup',
          ),
          ZoneSpot(
            id: 'bc_surf',
            zone: ZoneType.beach,
            name: 'Lớp học lướt ván',
            category: ZoneSpotCategory.beachActivity,
            description: 'Khóa học lướt sóng 90 phút với huấn luyện viên có chứng chỉ, phù hợp mùa sóng tháng 10 – 2.',
            image: AppImages.sonThuyPanorama,
            address: 'Bãi tắm Non Nước',
            openingHours: '06:00 – 17:00',
            priceRange: '450.000đ/buổi',
            latitude: 16.0008,
            longitude: 108.2683,
            rating: 4.6,
            tags: ['Có huấn luyện viên'],
          ),
          ZoneSpot(
            id: 'bc_kayak',
            zone: ZoneType.beach,
            name: 'Kayak & Thuyền thúng',
            category: ZoneSpotCategory.beachActivity,
            description: 'Chèo kayak đôi hoặc trải nghiệm thuyền thúng cùng ngư dân địa phương gần bờ.',
            image: AppImages.sonThuyBeach,
            address: 'Bãi tắm Tân Trà',
            openingHours: '06:00 – 17:00',
            priceRange: '100.000 – 200.000đ',
            latitude: 15.9952,
            longitude: 108.2741,
            rating: 4.4,
            tags: ['Gia đình'],
          ),
          ZoneSpot(
            id: 'bc_shower',
            zone: ZoneType.beach,
            name: 'Khu tắm nước ngọt & tủ đồ',
            category: ZoneSpotCategory.beachService,
            description: 'Phòng tắm nước ngọt, tủ khóa cá nhân, cho thuê khăn tắm.',
            image: AppImages.sonThuyBeach,
            address: 'Lối xuống biển Sơn Thủy',
            openingHours: '05:00 – 19:00',
            priceRange: '10.000 – 30.000đ',
            latitude: 16.0121,
            longitude: 108.2661,
            tags: ['Tiện ích'],
          ),
          ZoneSpot(
            id: 'bc_chair',
            zone: ZoneType.beach,
            name: 'Cho thuê ghế, dù che nắng',
            category: ZoneSpotCategory.beachService,
            description: 'Ghế nằm và dù che nắng theo ngày, có phục vụ nước dừa, nước mía tại chỗ.',
            image: AppImages.sonThuyBeach,
            address: 'Bãi tắm Sơn Thủy – Non Nước',
            openingHours: '06:00 – 18:00',
            priceRange: '40.000 – 80.000đ/ngày',
            latitude: 16.0089,
            longitude: 108.2672,
            tags: ['Tiện ích'],
          ),
        ],
      );

  static AirportWelcomeContent airport(String? campaignId) => AirportWelcomeContent(
        campaignId: campaignId ?? 'dad_airport_welcome_2026',
        headline: 'Chào mừng bạn đến Đà Nẵng!',
        message:
            'Chỉ khoảng 20 phút từ Sân bay Quốc tế Đà Nẵng, Ngũ Hành Sơn chào đón bạn với danh thắng núi đá cẩm thạch, '
            'làng đá mỹ nghệ trăm năm tuổi, bãi biển cát trắng và khu phố An Thượng sôi động.',
        heroImage: AppImages.marbleMountains,
        distanceFromAirport: 'Khoảng 9 km · 20 phút di chuyển',
        travelOptions: const [
          (icon: Icons.local_taxi_rounded, title: 'Taxi / Xe công nghệ', detail: 'Khoảng 120.000 – 180.000đ, đón tại cột ga đến quốc nội & quốc tế.'),
          (icon: Icons.directions_bus_rounded, title: 'Xe buýt', detail: 'Tham khảo các tuyến buýt nội thành đi qua đường Lê Văn Hiến.'),
          (icon: Icons.two_wheeler_rounded, title: 'Thuê xe máy', detail: 'Khoảng 120.000đ/ngày, luôn đội mũ bảo hiểm và mang theo giấy phép lái xe.'),
        ],
        quickFacts: const [
          (icon: Icons.terrain_rounded, value: '5', label: 'ngọn núi'),
          (icon: Icons.temple_buddhist_rounded, value: '10+', label: 'chùa & hang động'),
          (icon: Icons.handyman_rounded, value: '400+', label: 'năm làng đá'),
          (icon: Icons.beach_access_rounded, value: '5 km', label: 'bờ biển'),
        ],
        featuredDestinationIds: const ['ngu_hanh_son', 'dong_huyen_khong', 'lang_da_non_nuoc', 'bai_bien_son_thuy'],
        featuredEventIds: const ['ws_dieu_khac_da', 'ev_le_hoi_am_thuc_an_thuong', 'ev_dem_nhac_bien'],
        welcomeOffer: 'Quét mã QR tại các điểm đến Ngũ Hành Sơn để tích điểm và đổi quà lưu niệm đá Non Nước.',
      );
}
