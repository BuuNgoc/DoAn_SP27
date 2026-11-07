import '../../../../core/constants/app_images.dart';
import '../../domain/entities/event_entities.dart';

DateTime _at(int dayOffset, int hour, [int minute = 0]) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
}

/// Dữ liệu mẫu sự kiện, workshop, nghệ nhân và cuộc thi điêu khắc đá.
/// Tên nghệ nhân/thí sinh là nhân vật minh họa cho bản demo.
class EventSampleData {
  EventSampleData._();

  static List<EventWorkshop> events() => [
        EventWorkshop(
          id: 'ws_dieu_khac_da',
          title: 'Workshop Điêu khắc đá mini cùng nghệ nhân',
          kind: EventKind.workshop,
          category: 'Làng nghề',
          summary: 'Tự tay chạm khắc móc khóa hoặc tượng nhỏ bằng đá cẩm thạch trong 90 phút.',
          description:
              'Nghệ nhân Làng đá Non Nước sẽ hướng dẫn bạn từ khâu chọn đá, phác họa, đục thô đến mài bóng. '
              'Mỗi học viên được tặng một phôi đá cẩm thạch, bộ dụng cụ an toàn và mang sản phẩm hoàn thiện về làm kỷ niệm. '
              'Phù hợp cho cả trẻ em từ 8 tuổi (đi cùng người lớn).',
          startAt: _at(1, 8, 30),
          endAt: _at(1, 10),
          venue: 'Xưởng điêu khắc Non Nước',
          address: 'Làng đá mỹ nghệ Non Nước, đường Huyền Trân Công Chúa, Hòa Hải',
          latitude: 16.0005,
          longitude: 108.2632,
          price: 250000,
          capacity: 12,
          bookedCount: 7,
          coverImage: AppImages.artisanWorkshop,
          organizer: 'Hợp tác xã Làng đá mỹ nghệ Non Nước',
          schedule: [
            '08:30 – Đón khách, giới thiệu lịch sử làng nghề',
            '08:45 – Chọn phôi đá và phác họa mẫu',
            '09:00 – Thực hành đục, chạm khắc cùng nghệ nhân',
            '09:45 – Mài bóng, hoàn thiện và chụp ảnh lưu niệm',
          ],
          includes: ['Phôi đá cẩm thạch', 'Dụng cụ & kính bảo hộ', 'Nước uống', 'Hộp đựng sản phẩm'],
          artisanId: 'nghe_nhan_le_van_hung',
          isFeatured: true,
        ),
        EventWorkshop(
          id: 'ws_vong_tay_da',
          title: 'Workshop Mài đá làm vòng tay phong thủy',
          kind: EventKind.workshop,
          category: 'Làng nghề',
          summary: 'Mài, đánh bóng và xâu chuỗi vòng tay từ đá tự nhiên Non Nước.',
          description:
              'Tìm hiểu các loại đá tự nhiên và ý nghĩa ngũ hành, sau đó tự tay mài tròn hạt đá và thiết kế vòng tay theo mệnh của bạn.',
          startAt: _at(2, 14),
          endAt: _at(2, 15, 30),
          venue: 'Xưởng trang sức đá Non Nước',
          address: 'Làng đá mỹ nghệ Non Nước, Hòa Hải',
          latitude: 16.0001,
          longitude: 108.2628,
          price: 180000,
          capacity: 10,
          bookedCount: 10,
          coverImage: AppImages.nonNuocVillage,
          organizer: 'Xưởng trang sức đá Mai Non Nước',
          schedule: ['14:00 – Giới thiệu các loại đá', '14:20 – Mài và đánh bóng hạt', '15:00 – Xâu chuỗi, hoàn thiện'],
          includes: ['Đá nguyên liệu', 'Dây xâu chuyên dụng', 'Túi quà'],
          artisanId: 'nghe_nhan_nguyen_thi_mai',
        ),
        EventWorkshop(
          id: 'ws_am_thuc_an_thuong',
          title: 'Lớp nấu Mì Quảng & Bánh xèo xứ Quảng',
          kind: EventKind.workshop,
          category: 'Ẩm thực',
          summary: 'Đi chợ cùng đầu bếp địa phương và học nấu hai món đặc sản trứ danh.',
          description:
              'Bắt đầu bằng chuyến đi chợ Bắc Mỹ An chọn nguyên liệu, sau đó vào bếp học cách làm nước nhân mì Quảng, '
              'tráng bánh xèo giòn rụm và pha nước chấm chuẩn vị Đà Nẵng. Kết thúc bằng bữa trưa thưởng thức thành quả.',
          startAt: _at(2, 9),
          endAt: _at(2, 12),
          venue: 'Bếp nhà Quảng – An Thượng',
          address: 'An Thượng 26, phường Mỹ An',
          latitude: 16.0472,
          longitude: 108.2465,
          price: 350000,
          capacity: 16,
          bookedCount: 9,
          coverImage: AppImages.anThuongStreet,
          organizer: 'Bếp nhà Quảng',
          schedule: ['09:00 – Đi chợ Bắc Mỹ An', '09:45 – Nấu mì Quảng', '10:45 – Đổ bánh xèo', '11:30 – Thưởng thức'],
          includes: ['Nguyên liệu', 'Tạp dề', 'Bữa trưa', 'Công thức in sẵn'],
          isFeatured: true,
        ),
        EventWorkshop(
          id: 'ws_yoga_binh_minh',
          title: 'Yoga bình minh trên biển Non Nước',
          kind: EventKind.workshop,
          category: 'Biển & Sức khỏe',
          summary: 'Đón bình minh, tập thở và yoga nhẹ nhàng trên bãi cát.',
          description:
              'Buổi tập 75 phút phù hợp mọi trình độ với huấn luyện viên được chứng nhận. Kết thúc bằng nước dừa tươi và thời gian tự do tắm biển.',
          startAt: _at(3, 5, 15),
          endAt: _at(3, 6, 30),
          venue: 'Bãi biển Non Nước (chòi cứu hộ số 2)',
          address: 'Đường Trường Sa, Hòa Hải',
          latitude: 15.9995,
          longitude: 108.2702,
          price: 120000,
          capacity: 25,
          bookedCount: 14,
          coverImage: AppImages.sonThuyBeach,
          organizer: 'Sóng Yoga Đà Nẵng',
          includes: ['Thảm tập', 'Nước dừa'],
        ),
        EventWorkshop(
          id: 'ev_dem_nhac_bien',
          title: 'Đêm nhạc biển Sơn Thủy',
          kind: EventKind.event,
          category: 'Âm nhạc',
          summary: 'Chương trình âm nhạc acoustic ngoài trời bên bờ biển mỗi tối thứ Bảy.',
          description:
              'Các ban nhạc trẻ Đà Nẵng biểu diễn những ca khúc về biển và miền Trung. Khu vực ẩm thực đường phố, '
              'góc check-in đèn lồng và trò chơi dân gian dành cho gia đình.',
          startAt: _at(5, 19, 30),
          endAt: _at(5, 22),
          venue: 'Quảng trường biển Sơn Thủy',
          address: 'Đường Võ Nguyên Giáp, phường Khuê Mỹ',
          latitude: 16.0300,
          longitude: 108.2538,
          price: 0,
          capacity: 800,
          bookedCount: 312,
          coverImage: AppImages.sonThuyBeach,
          organizer: 'Trung tâm Văn hóa – Thể thao quận Ngũ Hành Sơn',
          schedule: ['19:00 – Mở cổng', '19:30 – Biểu diễn acoustic', '21:00 – Giao lưu khán giả', '22:00 – Kết thúc'],
        ),
        EventWorkshop(
          id: 'ev_trien_lam_hon_da',
          title: 'Triển lãm “Hồn đá Non Nước”',
          kind: EventKind.event,
          category: 'Triển lãm',
          summary: 'Trưng bày các tác phẩm dự thi Cuộc thi Điêu khắc đá Non Nước 2026.',
          description:
              'Hơn 60 tác phẩm điêu khắc đá của nghệ nhân và nhà điêu khắc trẻ được trưng bày. Du khách có thể bình chọn '
              'tác phẩm yêu thích ngay trên ứng dụng SmartTravel.',
          startAt: _at(-2, 8),
          endAt: _at(20, 17),
          venue: 'Nhà trưng bày Làng đá Non Nước',
          address: 'Làng đá mỹ nghệ Non Nước, Hòa Hải',
          latitude: 16.0008,
          longitude: 108.2640,
          price: 0,
          capacity: 2000,
          bookedCount: 640,
          coverImage: AppImages.stoneDragonCarving,
          organizer: 'Hiệp hội Làng nghề đá mỹ nghệ Non Nước',
          isFeatured: true,
        ),
        EventWorkshop(
          id: 'ev_le_hoi_am_thuc_an_thuong',
          title: 'Lễ hội Ẩm thực đường phố An Thượng',
          kind: EventKind.event,
          category: 'Ẩm thực',
          summary: 'Hơn 50 gian hàng ẩm thực Việt và quốc tế, nhạc sống, nghệ thuật đường phố.',
          description:
              'Khu phố An Thượng biến thành không gian lễ hội đi bộ với ẩm thực ba miền, món ăn quốc tế, '
              'biểu diễn đường phố và chợ phiên đồ thủ công.',
          startAt: _at(9, 17),
          endAt: _at(9, 23),
          venue: 'Khu phố An Thượng',
          address: 'An Thượng 2 – An Thượng 4, phường Mỹ An',
          latitude: 16.0478,
          longitude: 108.2460,
          price: 0,
          capacity: 3000,
          bookedCount: 980,
          coverImage: AppImages.anThuongStreet,
          organizer: 'UBND phường Mỹ An',
        ),
        EventWorkshop(
          id: 'ev_le_hoi_quan_the_am',
          title: 'Lễ hội Quán Thế Âm Ngũ Hành Sơn',
          kind: EventKind.event,
          category: 'Lễ hội tâm linh',
          summary: 'Lễ hội văn hóa – tâm linh truyền thống, tổ chức vào tháng Hai âm lịch.',
          description:
              'Lễ hội Quán Thế Âm là Di sản văn hóa phi vật thể quốc gia với phần lễ trang nghiêm (rước tượng, cầu an) '
              'và phần hội sôi nổi (thi đấu cờ người, hội hoa đăng, trò chơi dân gian).',
          startAt: _at(150, 7),
          endAt: _at(152, 21),
          venue: 'Chùa Quán Thế Âm, Danh thắng Ngũ Hành Sơn',
          address: 'Chân núi Kim Sơn, Ngũ Hành Sơn',
          latitude: 15.9990,
          longitude: 108.2600,
          price: 0,
          capacity: 5000,
          bookedCount: 1260,
          coverImage: AppImages.linhUngPagoda,
          organizer: 'Ban Quản lý Danh thắng Ngũ Hành Sơn',
        ),
      ];

  static const List<Artisan> artisans = [
    Artisan(
      id: 'nghe_nhan_le_van_hung',
      name: 'Nghệ nhân Lê Văn Hùng',
      title: 'Nghệ nhân điêu khắc đá – đời thứ tư của dòng họ',
      yearsOfExperience: 38,
      specialty: 'Tượng Phật, linh vật và phù điêu cỡ lớn',
      bio:
          'Sinh ra và lớn lên dưới chân Ngũ Hành Sơn, ông cầm đục từ năm 14 tuổi. Các tác phẩm của ông có mặt tại nhiều '
          'chùa chiền trong nước và được du khách quốc tế đặt làm quà tặng.',
      craftHistory:
          'Nghề điêu khắc đá Non Nước hình thành từ thế kỷ XVII, khi những người thợ từ Thanh Hóa vào lập nghiệp và khai thác '
          'đá tại chính Ngũ Hành Sơn. Từ năm 1990, việc khai thác đá tại núi bị cấm để bảo tồn danh thắng, làng nghề chuyển sang '
          'sử dụng đá nhập từ các địa phương khác nhưng vẫn giữ nguyên kỹ thuật chạm khắc truyền thống. Năm 2014, nghề đá '
          'mỹ nghệ Non Nước được công nhận là Di sản văn hóa phi vật thể quốc gia.',
      avatar: AppImages.artisanWorkshop,
      workshopAddress: 'Xưởng số 12, Làng đá mỹ nghệ Non Nước, Hòa Hải',
      featuredWorks: [
        ArtisanWork(title: 'Rồng cuộn mây', image: AppImages.stoneDragonCarving, material: 'Đá cẩm thạch trắng'),
        ArtisanWork(title: 'Quán Thế Âm cầm sen', image: AppImages.stoneLotusStatue, material: 'Đá hồng Thanh Hóa'),
        ArtisanWork(title: 'Phù điêu Ngũ Hành Sơn', image: AppImages.marbleMountains, material: 'Đá xanh'),
      ],
      awards: ['Giải Vàng Hội chợ Thủ công mỹ nghệ miền Trung 2019', 'Bàn tay vàng làng nghề Đà Nẵng 2022'],
      workshopIds: ['ws_dieu_khac_da'],
      rating: 4.9,
    ),
    Artisan(
      id: 'nghe_nhan_nguyen_thi_mai',
      name: 'Nghệ nhân Nguyễn Thị Mai',
      title: 'Nghệ nhân chế tác trang sức & đồ lưu niệm đá',
      yearsOfExperience: 22,
      specialty: 'Trang sức đá tự nhiên, đồ lưu niệm mini',
      bio:
          'Một trong số ít nữ nghệ nhân của làng đá, bà đưa chất liệu đá vào trang sức và đồ lưu niệm tinh xảo, '
          'giúp sản phẩm làng nghề gần gũi hơn với du khách trẻ.',
      craftHistory:
          'Bên cạnh tượng cỡ lớn, Non Nước còn nổi tiếng với dòng sản phẩm mỹ nghệ nhỏ như vòng tay, mặt dây chuyền, '
          'chặn giấy và tượng mini – những món quà lưu niệm được du khách yêu thích nhất khi đến Ngũ Hành Sơn.',
      avatar: AppImages.nonNuocVillage,
      workshopAddress: 'Xưởng trang sức đá Mai, Làng đá Non Nước',
      featuredWorks: [
        ArtisanWork(title: 'Vòng tay ngũ hành', image: AppImages.nonNuocVillage, material: 'Đá tự nhiên'),
        ArtisanWork(title: 'Sen đá chặn giấy', image: AppImages.stoneLotusStatue, material: 'Đá cẩm thạch'),
      ],
      awards: ['Sản phẩm lưu niệm du lịch tiêu biểu Đà Nẵng 2023'],
      workshopIds: ['ws_vong_tay_da'],
      rating: 4.8,
    ),
  ];

  static StoneCarvingContest contest() => StoneCarvingContest(
        id: 'contest_2026',
        title: 'Cuộc thi Điêu khắc đá Non Nước 2026',
        theme: 'Hồn đá xứ Quảng',
        description:
            'Cuộc thi thường niên tôn vinh tài năng điêu khắc đá của nghệ nhân và nhà điêu khắc trẻ. Tác phẩm được '
            'Hội đồng nghệ thuật chấm điểm (70%) kết hợp bình chọn của du khách trên ứng dụng SmartTravel (30%).',
        startAt: _at(-10, 8),
        votingEndsAt: _at(12, 23, 59),
        status: ContestStatus.voting,
        coverImage: AppImages.stoneDragonCarving,
        prizes: [
          'Giải Nhất: 30.000.000đ + Cúp “Bàn tay vàng”',
          'Giải Nhì: 20.000.000đ',
          'Giải Ba: 10.000.000đ',
          'Giải Bình chọn yêu thích: 5.000.000đ',
        ],
        rules: [
          'Mỗi tài khoản được bình chọn 1 lần cho mỗi tác phẩm.',
          'Kết quả bình chọn được cập nhật theo thời gian thực.',
          'Ban tổ chức có quyền loại bỏ lượt bình chọn gian lận.',
        ],
      );

  static const List<ContestEntry> entries = [
    ContestEntry(
      id: 'entry_01',
      contestId: 'contest_2026',
      title: 'Quán Thế Âm tọa sen',
      artistName: 'Phạm Thị Thu Hà',
      artistOrigin: 'Làng đá Non Nước',
      material: 'Đá hồng Thanh Hóa',
      dimensions: 'Cao 120 cm',
      description: 'Tượng Quán Thế Âm cầm hoa sen với nét mặt từ bi, các nếp áo được chạm mềm mại như lụa.',
      image: AppImages.stoneLotusStatue,
      voteCount: 1512,
    ),
    ContestEntry(
      id: 'entry_02',
      contestId: 'contest_2026',
      title: 'Rồng thiêng hộ quốc',
      artistName: 'Trần Minh Khoa',
      artistOrigin: 'Đà Nẵng',
      material: 'Đá cẩm thạch trắng',
      dimensions: '80 × 60 cm',
      description: 'Rồng cuộn mây ôm ngọc – biểu tượng của sức mạnh và sự che chở, từng vảy rồng được chạm thủ công.',
      image: AppImages.stoneDragonCarving,
      voteCount: 1248,
    ),
    ContestEntry(
      id: 'entry_03',
      contestId: 'contest_2026',
      title: 'Phật Thích Ca khất thực',
      artistName: 'Lê Quang Vinh',
      artistOrigin: 'Làng đá Non Nước',
      material: 'Đá cẩm thạch',
      dimensions: 'Cao 45 cm',
      description: 'Tác phẩm cỡ nhỏ thể hiện sự thanh tịnh, được hoàn thiện ngay tại xưởng trong 3 tháng.',
      image: AppImages.artisanWorkshop,
      voteCount: 987,
    ),
    ContestEntry(
      id: 'entry_04',
      contestId: 'contest_2026',
      title: 'Ngũ Hành Sơn – Bức phù điêu',
      artistName: 'Nguyễn Hữu Tài',
      artistOrigin: 'Quảng Nam',
      material: 'Đá xanh',
      dimensions: '150 × 90 cm',
      description: 'Phù điêu tái hiện năm ngọn núi Kim – Mộc – Thủy – Hỏa – Thổ bên dòng sông Cổ Cò xưa.',
      image: AppImages.marbleMountains,
      voteCount: 764,
    ),
    ContestEntry(
      id: 'entry_05',
      contestId: 'contest_2026',
      title: 'Làng đá bên sông Cổ Cò',
      artistName: 'Võ Thanh Bình',
      artistOrigin: 'Đà Nẵng',
      material: 'Đá vàng',
      dimensions: '100 × 70 cm',
      description: 'Tác phẩm ghi lại khung cảnh lao động của làng nghề với những người thợ đục đá bên hiên nhà.',
      image: AppImages.nonNuocVillage,
      voteCount: 532,
    ),
    ContestEntry(
      id: 'entry_06',
      contestId: 'contest_2026',
      title: 'Linh Ứng trong sương',
      artistName: 'Hồ Ngọc Ánh',
      artistOrigin: 'Huế',
      material: 'Đá trắng Nghệ An',
      dimensions: '70 × 50 cm',
      description: 'Mô hình chùa Linh Ứng ẩn hiện trong làn sương sớm, kết hợp kỹ thuật chạm lộng và mài mờ.',
      image: AppImages.linhUngPagoda,
      voteCount: 418,
    ),
  ];
}
