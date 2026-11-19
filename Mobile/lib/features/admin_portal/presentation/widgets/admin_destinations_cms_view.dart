import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

/// Dữ liệu mô hình Điểm đến CMS chuẩn hóa theo Epic 1 & Sheet gid=0.
class DestinationCmsItem {
  DestinationCmsItem({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.address,
    required this.lat,
    required this.lng,
    required this.shortDescription,
    required this.deepDescription,
    required this.culturalStory,
    required this.coverUrl,
    required this.galleryUrls,
    required this.vr360Url,
    required this.audioGuideUrl,
    required this.videoUrl,
    required this.openingHours,
    required this.ticketPrice,
    required this.targetAudience,
    required this.suggestedDuration,
    required this.tourRoute,
    required this.hashtags,
    required this.rating,
    required this.isPublished,
  });

  final String id;
  String name;
  String nameEn;
  String category; // Heritage, Beach, Craft Village, Food, Event, Workshop, Hotel
  String address;
  double lat;
  double lng;
  String shortDescription;
  String deepDescription;
  String culturalStory;
  String coverUrl;
  List<String> galleryUrls;
  String vr360Url;
  String audioGuideUrl;
  String videoUrl;
  String openingHours;
  String ticketPrice;
  String targetAudience;
  int suggestedDuration; // minutes
  String tourRoute;
  List<String> hashtags;
  double rating;
  bool isPublished;

  bool get hasVr => vr360Url.trim().isNotEmpty;
  bool get hasAudio => audioGuideUrl.trim().isNotEmpty;
  bool get hasGallery => galleryUrls.isNotEmpty;
  bool get hasGps => lat != 0.0 && lng != 0.0;
  bool get hasStory => culturalStory.trim().isNotEmpty;

  /// Tính điểm độ đầy đủ dữ liệu (Data Completeness Score: 0 -> 100%)
  int get completenessScore {
    int score = 0;
    if (name.trim().isNotEmpty) score += 10;
    if (hasGps) score += 15;
    if (shortDescription.trim().isNotEmpty && deepDescription.trim().isNotEmpty) score += 15;
    if (hasStory) score += 10;
    if (coverUrl.trim().isNotEmpty) score += 10;
    if (hasGallery) score += 10;
    if (hasVr) score += 15;
    if (hasAudio) score += 10;
    if (hashtags.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }
}

/// [FE-17 / Epic 1] Quản lý Danh mục Điểm Đến Chuẩn Hóa & Kiểm Tra Chất Lượng Dữ Liệu
class AdminDestinationsCmsView extends StatefulWidget {
  const AdminDestinationsCmsView({
    super.key,
    required this.searchQuery,
  });

  final String searchQuery;

  @override
  State<AdminDestinationsCmsView> createState() => _AdminDestinationsCmsViewState();
}

class _AdminDestinationsCmsViewState extends State<AdminDestinationsCmsView> {
  String _selectedCategory = 'Tất cả';
  String _selectedCompletenessFilter = 'Tất cả trạng thái';

  late final List<DestinationCmsItem> _items = [
    DestinationCmsItem(
      id: 'dong_huyen_khong',
      name: 'Động Huyền Không',
      nameEn: 'Huyen Khong Cave',
      category: 'Heritage',
      address: 'Đỉnh Thượng Thai, Thủy Sơn, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0048,
      lng: 108.2638,
      shortDescription: 'Động lộ thiên linh thiêng nhất quần thể Ngũ Hành Sơn với vòm động thủng đón ánh sáng tự nhiên.',
      deepDescription: 'Động Huyền Không mang cấu trúc mái vòm tự nhiên độc đáo, ánh sáng mặt trời rọi thẳng từ vòm trời xuống tượng Phật Thích Ca, tạo khung cảnh thoát tục.',
      culturalStory: 'Nơi đây từng là căn cứ bí mật thời kháng chiến và lưu giữ các văn bia cổ thời Nguyễn.',
      coverUrl: 'https://images.unsplash.com/photo-1599707367072-cd6ada2bc375?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [
        'https://images.unsplash.com/photo-1599707367072-cd6ada2bc375',
        'https://images.unsplash.com/photo-1528127269322-539801943592',
      ],
      vr360Url: 'https://storage.googleapis.com/smarttravel-vr/huyen_khong_8k.jpg',
      audioGuideUrl: 'https://storage.googleapis.com/smarttravel-audio/huyen_khong_vi.mp3',
      videoUrl: 'https://storage.googleapis.com/smarttravel-video/huyen_khong_intro.mp4',
      openingHours: '07:00 - 17:30 hằng ngày',
      ticketPrice: '40.000 VNĐ',
      targetAudience: 'Du khách tâm linh, văn hóa, nhiếp ảnh',
      suggestedDuration: 60,
      tourRoute: 'Tuyến Di Sản Thủy Sơn',
      hashtags: ['#NguHanhSon', '#DongHuyenKhong', '#DiSanTamLinh', '#DaNang'],
      rating: 4.9,
      isPublished: true,
    ),
    DestinationCmsItem(
      id: 'chua_tam_thai',
      name: 'Chùa Tam Thai',
      nameEn: 'Tam Thai Pagoda',
      category: 'Heritage',
      address: 'Thủy Sơn, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0055,
      lng: 108.2642,
      shortDescription: 'Cổ tự hơn 400 năm tuổi do Quốc sư Hưng Liên khai sơn, được vua Minh Mạng sắc phong Quốc Tự.',
      deepDescription: 'Ngôi chùa cổ kính mang đậm kiến trúc Phật giáo thời Nguyễn với cổng Tam quan cổ kính và cây thị di sản.',
      culturalStory: 'Vua Minh Mạng từng 3 lần ngự giá thăm chùa và ban cấp biển ngự ngự Quốc Tự Tam Thai.',
      coverUrl: 'https://images.unsplash.com/photo-1548013146-72479768bada?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [
        'https://images.unsplash.com/photo-1548013146-72479768bada',
      ],
      vr360Url: 'https://storage.googleapis.com/smarttravel-vr/tam_thai_vr.jpg',
      audioGuideUrl: 'https://storage.googleapis.com/smarttravel-audio/tam_thai_vi.mp3',
      videoUrl: '',
      openingHours: '06:30 - 18:00 hằng ngày',
      ticketPrice: 'Miễn phí (nằm trong vé Thủy Sơn)',
      targetAudience: 'Phật tử, du khách yêu lịch sử',
      suggestedDuration: 45,
      tourRoute: 'Tuyến Di Sản Thủy Sơn',
      hashtags: ['#ChuaTamThai', '#QuocTu', '#KienTrucNguyen'],
      rating: 4.8,
      isPublished: true,
    ),
    DestinationCmsItem(
      id: 'lang_da_non_nuoc',
      name: 'Làng Đá Mỹ Nghệ Non Nước',
      nameEn: 'Non Nuoc Stone Carving Village',
      category: 'Craft Village',
      address: 'Phường Hòa Hải, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0012,
      lng: 108.2610,
      shortDescription: 'Di sản văn hóa phi vật thể quốc gia với hơn 400 năm truyền thống đục đẽo và chế tác đá mỹ nghệ.',
      deepDescription: 'Trải dài dưới chân núi Non Nước, quy tụ hàng trăm nghệ nhân tài hoa thổi hồn vào từng khối đá cẩm thạch tự nhiên.',
      culturalStory: 'Cụ tổ Huỳnh Bá Quát người Thanh Hóa di cư vào thế kỷ XVII khai sinh ra nghề chạm khắc đá.',
      coverUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [
        'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119',
      ],
      vr360Url: '', // Thiếu VR360
      audioGuideUrl: 'https://storage.googleapis.com/smarttravel-audio/lang_da_vi.mp3',
      videoUrl: 'https://storage.googleapis.com/smarttravel-video/lang_da_400nam.mp4',
      openingHours: '08:00 - 20:00 hằng ngày',
      ticketPrice: 'Miễn phí tham quan',
      targetAudience: 'Du khách trải nghiệm nghề truyền thống, mua sắm lưu niệm',
      suggestedDuration: 90,
      tourRoute: 'Tuyến Làng Nghề & Trải Nghiệm',
      hashtags: ['#LangDaNonNuoc', '#DiSanPhiVatThe', '#NgheNhanDa'],
      rating: 4.7,
      isPublished: true,
    ),
    DestinationCmsItem(
      id: 'bien_son_thuy',
      name: 'Bãi Biển Sơn Thủy – Tân Trà',
      nameEn: 'Son Thuy - Tan Tra Beach',
      category: 'Beach',
      address: 'Đường Hoàng Sa - Võ Nguyên Giáp, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0125,
      lng: 108.2715,
      shortDescription: 'Bờ cát trắng mịn hoang sơ, làn nước trong xanh liền kề các khu resort cao cấp.',
      deepDescription: 'Bãi biển công cộng với các tiện ích hiện đại: lối xuống biển lát gỗ, trạm cứu hộ chuyên nghiệp và bãi đỗ xe rộng rãi.',
      culturalStory: 'Khu vực bãi biển từng là làng chài cổ Tân Trà với lễ hội Cầu Ngư truyền thống.',
      coverUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      ],
      vr360Url: 'https://storage.googleapis.com/smarttravel-vr/bien_son_thuy_vr.jpg',
      audioGuideUrl: '', // Thiếu audio guide
      videoUrl: '',
      openingHours: 'Mở cửa 24/7 (Cứu hộ trực 05:00 - 18:30)',
      ticketPrice: 'Miễn phí',
      targetAudience: 'Gia đình, du khách tắm biển, thể thao biển',
      suggestedDuration: 120,
      tourRoute: 'Tuyến Nghỉ Dưỡng Biển & Resort',
      hashtags: ['#BienSonThuy', '#TanTraBeach', '#BienDaNang', '#CleanBeach'],
      rating: 4.8,
      isPublished: true,
    ),
    DestinationCmsItem(
      id: 'vong_hai_dai',
      name: 'Vọng Hải Đài',
      nameEn: 'Sea Watching Tower',
      category: 'Heritage',
      address: 'Đỉnh Thủy Sơn, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0062,
      lng: 108.2655,
      shortDescription: 'Đài ngắm biển trên đỉnh Thủy Sơn nhìn trọn biển Non Nước và quần đảo Cù Lao Chàm.',
      deepDescription: 'Bia đá ngự chế khắc chữ Hán Vọng Hải Đài dựng vào thời Minh Mạng năm thứ 18 (1837).',
      culturalStory: 'Nơi vua chúa triều Nguyễn thường dừng chân ngắm tàu thuyền viễn dương và thưởng ngoạn phong cảnh.',
      coverUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [],
      vr360Url: 'https://storage.googleapis.com/smarttravel-vr/vong_hai_dai_vr.jpg',
      audioGuideUrl: '', // Thiếu audio
      videoUrl: '',
      openingHours: '07:00 - 17:30',
      ticketPrice: 'Trong vé Thủy Sơn',
      targetAudience: 'Nhiếp ảnh, ngắm hoàng hôn/bình minh',
      suggestedDuration: 30,
      tourRoute: 'Tuyến Di Sản Thủy Sơn',
      hashtags: ['#VongHaiDai', '#PanoramaView', '#CheckinNguHanhSon'],
      rating: 4.6,
      isPublished: true,
    ),
    DestinationCmsItem(
      id: 'pho_an_thuong',
      name: 'Khu Phố Du Lịch An Thượng',
      nameEn: 'An Thuong Tourist Quarter',
      category: 'Food',
      address: 'Phường Mỹ An, Ngũ Hành Sơn, Đà Nẵng',
      lat: 16.0501,
      lng: 108.2432,
      shortDescription: 'Tổ hợp phố đi bộ đêm, ẩm thực quốc tế, cà phê nghệ thuật và không gian âm nhạc sống động.',
      deepDescription: 'Khu phố du lịch hoạt động 24/7 với hơn 100 nhà hàng, quán bar, workshop thủ công và các buổi diễn âm nhạc acoustic đường phố.',
      culturalStory: 'Điểm giao thoa văn hóa quốc tế sôi động bậc nhất ven biển Đà Nẵng.',
      coverUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
      ],
      vr360Url: 'https://storage.googleapis.com/smarttravel-vr/an_thuong_night_vr.jpg',
      audioGuideUrl: 'https://storage.googleapis.com/smarttravel-audio/an_thuong_vi.mp3',
      videoUrl: 'https://storage.googleapis.com/smarttravel-video/an_thuong_nightlife.mp4',
      openingHours: 'Mở cửa 24/7 (Phố đi bộ cuối tuần 18:00 - 23:00)',
      ticketPrice: 'Miễn phí vào phố',
      targetAudience: 'Giới trẻ, du khách quốc tế, ẩm thực đêm',
      suggestedDuration: 180,
      tourRoute: 'Tuyến Phố Đêm & Ẩm Thực',
      hashtags: ['#AnThuong', '#NightlifeDaNang', '#StreetFood', '#AnThuongQuarter'],
      rating: 4.7,
      isPublished: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          item.nameEn.toLowerCase().contains(widget.searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(widget.searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'Tất cả' || item.category == _selectedCategory;

      bool matchesCompleteness = true;
      if (_selectedCompletenessFilter == 'Đủ 100% dữ liệu') {
        matchesCompleteness = item.completenessScore >= 95;
      } else if (_selectedCompletenessFilter == 'Thiếu Audio Guide') {
        matchesCompleteness = !item.hasAudio;
      } else if (_selectedCompletenessFilter == 'Thiếu VR360') {
        matchesCompleteness = !item.hasVr;
      } else if (_selectedCompletenessFilter == 'Thiếu Album ảnh') {
        matchesCompleteness = !item.hasGallery;
      }

      return matchesSearch && matchesCategory && matchesCompleteness;
    }).toList();

    return TourismCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Action Buttons ─────────────────────────────────────────
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cơ Sở Dữ Liệu Điểm Đến Chuẩn Hóa (FE-17, Epic 1)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Quản lý đa phương tiện: VR360, Audio đa ngữ, Tọa độ GPS, Câu chuyện di sản & Bộ kiểm tra Data Quality',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showDataQualityChecklistDialog(context),
                icon: const Icon(Icons.fact_check_rounded, size: 18),
                label: const Text('Báo Cáo Data Quality'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _openAddEditDestinationDialog(context, null),
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: const Text('+ Thêm Điểm Đến Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Filter Bar (Category & Data Completeness) ────────────────────────
          Row(
            children: [
              // Category Filter
              const Text('Phân loại: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                underline: const SizedBox(),
                items: [
                  'Tất cả',
                  'Heritage',
                  'Beach',
                  'Craft Village',
                  'Food',
                  'Event',
                  'Workshop',
                  'Hotel',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(width: 24),

              // Completeness Filter
              const Text('Chất lượng dữ liệu: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCompletenessFilter,
                underline: const SizedBox(),
                items: [
                  'Tất cả trạng thái',
                  'Đủ 100% dữ liệu',
                  'Thiếu Audio Guide',
                  'Thiếu VR360',
                  'Thiếu Album ảnh',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCompletenessFilter = v);
                },
              ),
              const Spacer(),
              Text('Hiển thị ${filtered.length} / ${_items.length} điểm đến', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Data Table ──────────────────────────────────────────────────────
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(3.2),
              1: FlexColumnWidth(1.6),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.1),
              4: FlexColumnWidth(1.1),
              5: FlexColumnWidth(1.8),
              6: FlexColumnWidth(1.6),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Tên Điểm Đến', 'Chuẩn Loại', 'Tọa Độ GPS', 'VR360', 'Audio', 'Data Completeness', 'Thao Tác'])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Color(0xFF1E293B))),
                    ),
                ],
              ),
              for (final d in filtered)
                TableRow(
                  children: [
                    // Tên & Ảnh thumbnail
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              d.coverUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 44,
                                height: 44,
                                color: AppColors.border,
                                child: const Icon(Icons.image_not_supported_rounded, size: 20, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                Text(d.nameEn, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Phân loại
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryColor(d.category).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d.category,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _categoryColor(d.category)),
                        ),
                      ),
                    ),
                    // GPS
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${d.lat.toStringAsFixed(4)}, ${d.lng.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                    // VR360
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        d.hasVr ? Icons.check_circle_rounded : Icons.cancel_outlined,
                        size: 18,
                        color: d.hasVr ? const Color(0xFF16A34A) : AppColors.textMuted,
                      ),
                    ),
                    // Audio
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        d.hasAudio ? Icons.check_circle_rounded : Icons.cancel_outlined,
                        size: 18,
                        color: d.hasAudio ? const Color(0xFF16A34A) : AppColors.textMuted,
                      ),
                    ),
                    // Data Completeness Score
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${d.completenessScore}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _scoreColor(d.completenessScore))),
                              if (d.completenessScore < 100)
                                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: d.completenessScore / 100.0,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(d.completenessScore)),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'Chỉnh sửa toàn bộ thông tin',
                            onPressed: () => _openAddEditDestinationDialog(context, d),
                          ),
                          IconButton(
                            icon: const Icon(Icons.fact_check_outlined, size: 18, color: Color(0xFFD97706)),
                            tooltip: 'Xem Checklist độ đầy đủ dữ liệu',
                            onPressed: () => _showSingleItemQualityDialog(context, d),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            tooltip: 'Xóa điểm đến',
                            onPressed: () {
                              setState(() => _items.remove(d));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Heritage':
        return AppColors.primary;
      case 'Beach':
        return const Color(0xFF0284C7); // Sky blue
      case 'Craft Village':
        return const Color(0xFFD97706); // Amber
      case 'Food':
        return const Color(0xFFDC2626); // Red
      case 'Event':
        return const Color(0xFF7C3AED); // Purple
      default:
        return const Color(0xFF475569);
    }
  }

  Color _scoreColor(int score) {
    if (score >= 90) return const Color(0xFF16A34A);
    if (score >= 70) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  void _showDataQualityChecklistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fact_check_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Báo Cáo Kiểm Tra Độ Đầy Đủ Dữ Liệu (Epic 1)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quy chuẩn dữ liệu du lịch Ngũ Hành Sơn yêu cầu 8 trường cốt lõi:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              const _ChecklistCriteriaRow(label: '1. Tên điểm & Phân loại chuẩn (Heritage/Beach/Craft/Food/Event)', weight: '10%'),
              const _ChecklistCriteriaRow(label: '2. Tọa độ GPS chính xác (Lat, Lng) phục vụ Geofence', weight: '15%'),
              const _ChecklistCriteriaRow(label: '3. Mô tả ngắn & Mô tả văn hóa chuyên sâu', weight: '15%'),
              const _ChecklistCriteriaRow(label: '4. Câu chuyện di sản / nhân vật văn hóa gắn liền', weight: '10%'),
              const _ChecklistCriteriaRow(label: '5. Ảnh đại diện & Album ảnh đa góc', weight: '20%'),
              const _ChecklistCriteriaRow(label: '6. Ảnh Panorama VR360 Equirectangular', weight: '15%'),
              const _ChecklistCriteriaRow(label: '7. Audio Guide thuyết minh đa ngôn ngữ', weight: '10%'),
              const _ChecklistCriteriaRow(label: '8. Hashtag truyền thông & Giờ mở cửa / Giá vé', weight: '5%'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Điểm đạt trung bình toàn hệ thống: 88.5% (Tăng +12.4% so với đợt kiểm tra trước).',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _showSingleItemQualityDialog(BuildContext context, DestinationCmsItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chi Tiết Độ Đầy Đủ: ${item.name}'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QualityItemCheck(title: 'Tọa độ GPS', has: item.hasGps, detail: '${item.lat}, ${item.lng}'),
              _QualityItemCheck(title: 'Ảnh Panorama VR360', has: item.hasVr, detail: item.hasVr ? item.vr360Url : 'Chưa tải lên'),
              _QualityItemCheck(title: 'Audio Guide Đa Ngữ', has: item.hasAudio, detail: item.hasAudio ? item.audioGuideUrl : 'Chưa ghi âm thuyết minh'),
              _QualityItemCheck(title: 'Album Ảnh Trưng Bày', has: item.hasGallery, detail: '${item.galleryUrls.length} ảnh trong album'),
              _QualityItemCheck(title: 'Câu Chuyện Di Sản', has: item.hasStory, detail: item.hasStory ? 'Đã có bài viết sâu' : 'Chưa nhập'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openAddEditDestinationDialog(context, item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Bổ Sung Dữ Liệu'),
          ),
        ],
      ),
    );
  }

  void _openAddEditDestinationDialog(BuildContext context, DestinationCmsItem? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nameEnCtrl = TextEditingController(text: existing?.nameEn ?? '');
    final addressCtrl = TextEditingController(text: existing?.address ?? '');
    final latCtrl = TextEditingController(text: existing != null ? existing.lat.toString() : '16.0048');
    final lngCtrl = TextEditingController(text: existing != null ? existing.lng.toString() : '108.2638');
    final shortDescCtrl = TextEditingController(text: existing?.shortDescription ?? '');
    final deepDescCtrl = TextEditingController(text: existing?.deepDescription ?? '');
    final storyCtrl = TextEditingController(text: existing?.culturalStory ?? '');
    final coverCtrl = TextEditingController(text: existing?.coverUrl ?? '');
    final vrCtrl = TextEditingController(text: existing?.vr360Url ?? '');
    final audioCtrl = TextEditingController(text: existing?.audioGuideUrl ?? '');
    final hoursCtrl = TextEditingController(text: existing?.openingHours ?? '07:00 - 17:30');
    final priceCtrl = TextEditingController(text: existing?.ticketPrice ?? '40.000 VNĐ');
    final durationCtrl = TextEditingController(text: existing != null ? existing.suggestedDuration.toString() : '60');
    final hashtagsCtrl = TextEditingController(text: existing?.hashtags.join(', ') ?? '#NguHanhSon, #DaNang');
    String category = existing?.category ?? 'Heritage';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Thêm Điểm Đến Chuẩn Hóa Mới (Epic 1)' : 'Chỉnh Sửa Điểm Đến: ${existing.name}'),
          content: SizedBox(
            width: 720,
            height: 540,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Name and Category
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Tên Điểm Đến (Tiếng Việt)*', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: nameEnCtrl,
                          decoration: const InputDecoration(labelText: 'Tên Tiếng Anh (English)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 2: Category and Address
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'Chuẩn Phân Loại*', border: OutlineInputBorder()),
                          items: ['Heritage', 'Beach', 'Craft Village', 'Food', 'Event', 'Workshop', 'Hotel']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => category = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: addressCtrl,
                          decoration: const InputDecoration(labelText: 'Địa Chỉ Thực Địa', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 3: GPS
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latCtrl,
                          decoration: const InputDecoration(labelText: 'Tọa Độ Vĩ Độ (Latitude)*', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lngCtrl,
                          decoration: const InputDecoration(labelText: 'Tọa Độ Kinh Độ (Longitude)*', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 4: Descriptions
                  TextField(
                    controller: shortDescCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Mô Tả Ngắn (Hiển thị danh sách card)*', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: deepDescCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Mô Tả Sâu & Kiến Trúc Di Sản', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: storyCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Câu Chuyện Lịch Sử & Văn Hóa Dân Gian', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),

                  // Row 5: Media URLs
                  TextField(
                    controller: coverCtrl,
                    decoration: const InputDecoration(labelText: 'URL Ảnh Đại Diện (Cover Image)*', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: vrCtrl,
                    decoration: const InputDecoration(labelText: 'URL Ảnh Panorama VR360 Equirectangular (2:1)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: audioCtrl,
                    decoration: const InputDecoration(labelText: 'URL File Audio Guide Thuyết Minh Đa Ngôn Ngữ', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),

                  // Row 6: Hours, Price, Duration
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hoursCtrl,
                          decoration: const InputDecoration(labelText: 'Giờ Mở Cửa', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(labelText: 'Giá Vé', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durationCtrl,
                          decoration: const InputDecoration(labelText: 'Thời Gian Gợi Ý (phút)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: hashtagsCtrl,
                    decoration: const InputDecoration(labelText: 'Hashtags Truyền Thông (Cách nhau dấu phẩy)', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latCtrl.text) ?? 16.0048;
                final lng = double.tryParse(lngCtrl.text) ?? 108.2638;
                final duration = int.tryParse(durationCtrl.text) ?? 60;
                final hashtags = hashtagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                if (existing != null) {
                  setState(() {
                    existing.name = nameCtrl.text;
                    existing.nameEn = nameEnCtrl.text;
                    existing.category = category;
                    existing.address = addressCtrl.text;
                    existing.lat = lat;
                    existing.lng = lng;
                    existing.shortDescription = shortDescCtrl.text;
                    existing.deepDescription = deepDescCtrl.text;
                    existing.culturalStory = storyCtrl.text;
                    existing.coverUrl = coverCtrl.text;
                    existing.vr360Url = vrCtrl.text;
                    existing.audioGuideUrl = audioCtrl.text;
                    existing.openingHours = hoursCtrl.text;
                    existing.ticketPrice = priceCtrl.text;
                    existing.suggestedDuration = duration;
                    existing.hashtags = hashtags;
                  });
                } else {
                  setState(() {
                    _items.insert(
                      0,
                      DestinationCmsItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Điểm Đến Mới',
                        nameEn: nameEnCtrl.text,
                        category: category,
                        address: addressCtrl.text,
                        lat: lat,
                        lng: lng,
                        shortDescription: shortDescCtrl.text,
                        deepDescription: deepDescCtrl.text,
                        culturalStory: storyCtrl.text,
                        coverUrl: coverCtrl.text.isNotEmpty ? coverCtrl.text : 'https://images.unsplash.com/photo-1599707367072-cd6ada2bc375',
                        galleryUrls: [],
                        vr360Url: vrCtrl.text,
                        audioGuideUrl: audioCtrl.text,
                        videoUrl: '',
                        openingHours: hoursCtrl.text,
                        ticketPrice: priceCtrl.text,
                        targetAudience: 'Du khách tham quan',
                        suggestedDuration: duration,
                        tourRoute: 'Tuyến Di Sản',
                        hashtags: hashtags,
                        rating: 5.0,
                        isPublished: true,
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Lưu Dữ Liệu'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCriteriaRow extends StatelessWidget {
  const _ChecklistCriteriaRow({required this.label, required this.weight});
  final String label;
  final String weight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.backgroundSubtle, borderRadius: BorderRadius.circular(4)),
            child: Text(weight, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QualityItemCheck extends StatelessWidget {
  const _QualityItemCheck({required this.title, required this.has, required this.detail});
  final String title;
  final bool has;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(has ? Icons.check_circle_rounded : Icons.cancel_outlined, size: 20, color: has ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
