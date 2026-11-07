import '../../../../core/constants/app_images.dart';
import '../../domain/entities/destination.dart';
import '../models/destination_model.dart';

/// Dữ liệu mẫu 9 điểm đến tiêu biểu tại quận Ngũ Hành Sơn.
/// Giá vé và giờ mở cửa mang tính tham khảo cho bản demo.
class DestinationSampleData {
  DestinationSampleData._();

  static const List<DestinationModel> destinations = [
    DestinationModel(
      id: 'ngu_hanh_son',
      name: 'Danh thắng Ngũ Hành Sơn',
      category: DestinationCategory.mountainCave,
      shortDescription: 'Quần thể 5 ngọn núi đá vôi Kim, Mộc, Thủy, Hỏa, Thổ giữa lòng Đà Nẵng.',
      overview:
          'Ngũ Hành Sơn là quần thể năm ngọn núi đá vôi mang tên Kim Sơn, Mộc Sơn, Thủy Sơn, Hỏa Sơn và Thổ Sơn. '
          'Thủy Sơn là ngọn núi lớn và cao nhất, nơi tập trung nhiều chùa chiền, hang động và vọng cảnh đài nhìn ra biển Đông. '
          'Du khách có thể leo bậc đá hoặc đi thang máy để tham quan các điểm nổi bật trong khoảng 2 – 3 giờ.',
      culturalHistory:
          'Danh thắng gắn liền với đời sống tâm linh của cư dân xứ Quảng qua nhiều thế kỷ. '
          'Dưới triều Nguyễn, vua Minh Mạng nhiều lần ngự giá đến thăm và cho xây dựng, trùng tu chùa chiền tại đây. '
          'Năm 2018, Danh thắng Ngũ Hành Sơn được xếp hạng là Di tích quốc gia đặc biệt; hệ thống bia ký Ma nhai tại đây '
          'cũng được UNESCO ghi danh vào Danh mục Di sản tư liệu thế giới khu vực châu Á – Thái Bình Dương.',
      address: '81 Huyền Trân Công Chúa, phường Hòa Hải, quận Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '07:00 – 17:30 hằng ngày',
      ticketInfo: 'Vé núi Thủy Sơn: 40.000đ/người · Thang máy: 15.000đ/lượt (giá tham khảo)',
      latitude: 16.0036,
      longitude: 108.2638,
      coverImage: AppImages.marbleMountains,
      gallery: [AppImages.marbleMountains, AppImages.linhUngPagoda, AppImages.huyenKhongCave],
      videoCount: 2,
      hasVr360: true,
      hasAudioGuide: true,
      ratingAvg: 4.8,
      reviewCount: 1284,
      tags: ['Di tích quốc gia đặc biệt', 'Leo núi', 'Ngắm cảnh'],
      visitDurationMinutes: 180,
      highlights: ['Vọng Giang Đài', 'Động Huyền Không', 'Chùa Linh Ứng', 'Thang máy lên Thủy Sơn'],
    ),
    DestinationModel(
      id: 'dong_huyen_khong',
      name: 'Động Huyền Không',
      category: DestinationCategory.mountainCave,
      shortDescription: 'Hang động lớn và đẹp nhất trên núi Thủy Sơn với những cột nắng huyền ảo.',
      overview:
          'Động Huyền Không có vòm trần cao, nhiều khe hở đón ánh sáng tự nhiên tạo thành những cột nắng rọi xuống lòng động, '
          'đẹp nhất vào khoảng 9 – 11 giờ sáng. Trong động có tượng Phật Thích Ca bằng đá, các am thờ nhỏ và nhiều nhũ đá có hình thù độc đáo.',
      culturalHistory:
          'Động từng là nơi tu hành và thờ tự từ thời các chúa Nguyễn. Trên vách đá còn lưu giữ nhiều bia ký chữ Hán – Nôm '
          'khắc thơ văn của vua quan triều Nguyễn, là một phần quý giá của hệ thống bia Ma nhai Ngũ Hành Sơn.',
      address: 'Núi Thủy Sơn, Danh thắng Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '07:00 – 17:30 hằng ngày',
      ticketInfo: 'Đã bao gồm trong vé tham quan núi Thủy Sơn',
      latitude: 16.0042,
      longitude: 108.2627,
      coverImage: AppImages.huyenKhongCave,
      gallery: [AppImages.huyenKhongCave, AppImages.huyenKhongPanorama, AppImages.marbleMountains],
      videoCount: 1,
      hasVr360: true,
      hasAudioGuide: true,
      ratingAvg: 4.9,
      reviewCount: 862,
      tags: ['Hang động', 'Tâm linh', 'Chụp ảnh'],
      visitDurationMinutes: 45,
      highlights: ['Cột nắng tự nhiên', 'Tượng Phật Thích Ca', 'Bia ký Ma nhai'],
    ),
    DestinationModel(
      id: 'chua_linh_ung_non_nuoc',
      name: 'Chùa Linh Ứng Non Nước',
      category: DestinationCategory.pagoda,
      shortDescription: 'Ngôi chùa cổ trên đỉnh Thủy Sơn, nhìn thẳng ra bãi biển Non Nước.',
      overview:
          'Chùa Linh Ứng nằm trên sườn núi Thủy Sơn, phía trước là tượng Quan Thế Âm Bồ Tát bằng đá trắng và khoảng sân rộng '
          'nhìn ra biển. Không gian chùa thanh tịnh, rợp bóng cây đại (hoa sứ), phù hợp để vãn cảnh và chiêm bái.',
      culturalHistory:
          'Chùa có tên cũ là Ứng Chân, được đổi tên thành Linh Ứng dưới triều vua Minh Mạng. '
          'Đây là một trong những ngôi chùa có lịch sử lâu đời nhất của quần thể Ngũ Hành Sơn và là điểm hành hương quen thuộc của Phật tử Đà Nẵng.',
      address: 'Núi Thủy Sơn, Danh thắng Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '06:00 – 18:00 hằng ngày',
      ticketInfo: 'Đã bao gồm trong vé tham quan núi Thủy Sơn',
      latitude: 16.0047,
      longitude: 108.2633,
      coverImage: AppImages.linhUngPagoda,
      gallery: [AppImages.linhUngPagoda, AppImages.marbleMountains],
      videoCount: 1,
      hasVr360: true,
      hasAudioGuide: true,
      ratingAvg: 4.7,
      reviewCount: 540,
      tags: ['Chùa cổ', 'Tâm linh', 'View biển'],
      visitDurationMinutes: 40,
      highlights: ['Tượng Quan Âm đá trắng', 'Sân chùa nhìn ra biển', 'Cây đại cổ thụ'],
    ),
    DestinationModel(
      id: 'chua_tam_thai',
      name: 'Chùa Tam Thai',
      category: DestinationCategory.pagoda,
      shortDescription: 'Quốc tự triều Nguyễn với kiến trúc cổ kính trên núi Thủy Sơn.',
      overview:
          'Chùa Tam Thai tọa lạc gần lối lên chính của núi Thủy Sơn, có cổng tam quan, chính điện thờ Phật và lầu chuông cổ. '
          'Từ chùa có lối đi đến Vọng Hải Đài để ngắm toàn cảnh biển Non Nước.',
      culturalHistory:
          'Dưới thời vua Minh Mạng, chùa Tam Thai được trùng tu và xếp vào hàng quốc tự – chùa do triều đình trực tiếp bảo trợ. '
          'Chùa còn lưu giữ nhiều hiện vật và văn bia có giá trị lịch sử.',
      address: 'Núi Thủy Sơn, Danh thắng Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '06:00 – 18:00 hằng ngày',
      ticketInfo: 'Đã bao gồm trong vé tham quan núi Thủy Sơn',
      latitude: 16.0039,
      longitude: 108.2641,
      coverImage: AppImages.marbleMountains,
      gallery: [AppImages.marbleMountains, AppImages.linhUngPagoda],
      hasVr360: false,
      hasAudioGuide: true,
      ratingAvg: 4.6,
      reviewCount: 318,
      tags: ['Quốc tự', 'Kiến trúc cổ'],
      visitDurationMinutes: 30,
      highlights: ['Cổng tam quan', 'Vọng Hải Đài', 'Lầu chuông cổ'],
    ),
    DestinationModel(
      id: 'dong_am_phu',
      name: 'Động Âm Phủ',
      category: DestinationCategory.mountainCave,
      shortDescription: 'Hang động gắn với truyền thuyết cõi âm dương, trải nghiệm khám phá độc đáo.',
      overview:
          'Động Âm Phủ nằm dưới chân núi Thủy Sơn, gồm nhiều ngách động nối tiếp với lối đi quanh co, cầu Âm Dương và các tượng điêu khắc '
          'tái hiện quan niệm dân gian về cõi âm. Có lối leo lên khe đá dẫn ra ánh sáng tượng trưng cho lối lên thiên đàng.',
      culturalHistory:
          'Không gian động phản ánh tín ngưỡng dân gian và triết lý nhân quả của Phật giáo, khuyên con người sống hướng thiện.',
      address: 'Chân núi Thủy Sơn, Danh thắng Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '07:00 – 17:30 hằng ngày',
      ticketInfo: 'Vé tham quan động: 20.000đ/người (giá tham khảo)',
      latitude: 16.0018,
      longitude: 108.2645,
      coverImage: AppImages.huyenKhongCave,
      gallery: [AppImages.huyenKhongCave],
      hasVr360: false,
      hasAudioGuide: true,
      ratingAvg: 4.5,
      reviewCount: 276,
      tags: ['Hang động', 'Phiêu lưu'],
      visitDurationMinutes: 40,
      highlights: ['Cầu Âm Dương', 'Lối lên Thiên đàng'],
    ),
    DestinationModel(
      id: 'lang_da_non_nuoc',
      name: 'Làng đá mỹ nghệ Non Nước',
      category: DestinationCategory.craftVillage,
      shortDescription: 'Làng nghề điêu khắc đá truyền thống hàng trăm năm dưới chân Ngũ Hành Sơn.',
      overview:
          'Dọc đường Huyền Trân Công Chúa là hàng trăm cơ sở chế tác đá mỹ nghệ, từ tượng Phật, sư tử đá đến đồ trang trí nhỏ. '
          'Du khách có thể xem nghệ nhân chế tác trực tiếp, tham gia workshop khắc đá và chọn mua quà lưu niệm.',
      culturalHistory:
          'Làng nghề hình thành từ khoảng thế kỷ XVIII, gắn với công lao của tổ nghề Huỳnh Bá Quát. '
          'Ban đầu nghệ nhân khai thác đá trực tiếp từ Ngũ Hành Sơn; ngày nay việc khai thác đã chấm dứt để bảo tồn danh thắng, '
          'đá nguyên liệu được đưa từ các địa phương khác về chế tác.',
      address: 'Đường Huyền Trân Công Chúa, phường Hòa Hải, quận Ngũ Hành Sơn, Đà Nẵng',
      openingHours: '07:30 – 18:00 hằng ngày',
      ticketInfo: 'Miễn phí tham quan · Workshop có tính phí',
      latitude: 15.9991,
      longitude: 108.2640,
      coverImage: AppImages.nonNuocVillage,
      gallery: [AppImages.nonNuocVillage, AppImages.marbleMountains],
      videoCount: 3,
      hasVr360: true,
      hasAudioGuide: true,
      ratingAvg: 4.7,
      reviewCount: 455,
      tags: ['Làng nghề', 'Workshop', 'Quà lưu niệm'],
      visitDurationMinutes: 90,
      highlights: ['Xem nghệ nhân chế tác', 'Workshop khắc đá', 'Cuộc thi điêu khắc đá'],
    ),
    DestinationModel(
      id: 'bai_bien_son_thuy',
      name: 'Bãi biển Sơn Thủy',
      category: DestinationCategory.beach,
      shortDescription: 'Bãi cát trắng mịn, nước trong xanh, thích hợp tắm biển và chèo thúng.',
      overview:
          'Bãi biển Sơn Thủy nằm gần chân Ngũ Hành Sơn, bờ cát thoai thoải và sóng tương đối êm vào mùa hè. '
          'Có khu tắm công cộng, chòi cứu hộ, dịch vụ thuê ghế, thúng chai và các môn thể thao biển.',
      culturalHistory:
          'Khu vực ven biển từng là làng chài truyền thống; hình ảnh thuyền thúng vẫn là nét đặc trưng của biển Ngũ Hành Sơn.',
      address: 'Đường Trường Sa, phường Hòa Hải, quận Ngũ Hành Sơn, Đà Nẵng',
      openingHours: 'Mở cửa cả ngày · Cứu hộ trực 05:00 – 18:00',
      ticketInfo: 'Miễn phí',
      latitude: 16.0072,
      longitude: 108.2702,
      coverImage: AppImages.sonThuyBeach,
      gallery: [AppImages.sonThuyBeach],
      videoCount: 1,
      hasVr360: true,
      hasAudioGuide: false,
      ratingAvg: 4.6,
      reviewCount: 690,
      tags: ['Tắm biển', 'Thể thao biển', 'Bình minh'],
      visitDurationMinutes: 120,
      highlights: ['Bình minh trên biển', 'Chèo thúng chai', 'Chèo SUP'],
      beachSafetyInfo:
          'Chỉ tắm trong khu vực có phao và cờ báo an toàn, khi có nhân viên cứu hộ trực. '
          'Không tắm khi có cờ đỏ, khi trời tối hoặc khi đã uống rượu bia. Cẩn trọng dòng rip (dòng chảy xa bờ) vào mùa gió Đông Bắc.',
    ),
    DestinationModel(
      id: 'bai_bien_non_nuoc',
      name: 'Bãi biển Non Nước',
      category: DestinationCategory.beach,
      shortDescription: 'Một trong những bãi biển đẹp nhất Đà Nẵng, yên tĩnh và hoang sơ.',
      overview:
          'Bãi biển Non Nước trải dài phía nam quận Ngũ Hành Sơn, không gian thoáng đãng với hàng dương xanh, '
          'thích hợp cho gia đình nghỉ dưỡng, dạo biển buổi chiều và ngắm bình minh.',
      culturalHistory:
          'Cái tên Non Nước gợi sự hòa quyện giữa núi (non) và biển (nước) – nét đặc trưng của cảnh quan nơi đây.',
      address: 'Đường Trường Sa, phường Hòa Hải, quận Ngũ Hành Sơn, Đà Nẵng',
      openingHours: 'Mở cửa cả ngày · Cứu hộ trực 05:00 – 18:00',
      ticketInfo: 'Miễn phí',
      latitude: 15.9962,
      longitude: 108.2712,
      coverImage: AppImages.sonThuyBeach,
      gallery: [AppImages.sonThuyBeach],
      hasVr360: false,
      hasAudioGuide: false,
      ratingAvg: 4.5,
      reviewCount: 402,
      tags: ['Yên tĩnh', 'Gia đình'],
      visitDurationMinutes: 120,
      highlights: ['Hàng dương ven biển', 'Ngắm bình minh'],
      beachSafetyInfo:
          'Một số đoạn biển chưa có cứu hộ thường trực – chỉ tắm tại khu vực có biển báo cho phép. '
          'Trẻ em cần có người lớn đi kèm, sử dụng áo phao khi chơi thể thao dưới nước.',
    ),
    DestinationModel(
      id: 'pho_an_thuong',
      name: 'Phố Tây An Thượng',
      category: DestinationCategory.anThuong,
      shortDescription: 'Khu phố sôi động với ẩm thực quốc tế, cà phê và cuộc sống về đêm.',
      overview:
          'An Thượng là khu phố du lịch nhộn nhịp gần biển Mỹ Khê, tập trung nhiều nhà hàng Âu – Á, quán cà phê, '
          'quầy bar và khách sạn nhỏ. Buổi tối, các con phố lên đèn và trở thành điểm hẹn của du khách trong và ngoài nước.',
      culturalHistory:
          'Từ một khu dân cư ven biển, An Thượng phát triển thành "phố Tây" của Đà Nẵng nhờ lượng du khách quốc tế lưu trú ngày càng đông.',
      address: 'Khu An Thượng, phường Mỹ An, quận Ngũ Hành Sơn, Đà Nẵng',
      openingHours: 'Sôi động nhất 17:00 – 24:00',
      ticketInfo: 'Miễn phí',
      latitude: 16.0490,
      longitude: 108.2460,
      coverImage: AppImages.anThuongStreet,
      gallery: [AppImages.anThuongStreet],
      videoCount: 1,
      hasVr360: false,
      hasAudioGuide: false,
      ratingAvg: 4.4,
      reviewCount: 735,
      tags: ['Ẩm thực', 'Về đêm', 'Cà phê'],
      visitDurationMinutes: 150,
      highlights: ['Ẩm thực quốc tế', 'Quán bar & live music', 'Cà phê ven phố'],
    ),
  ];
}
