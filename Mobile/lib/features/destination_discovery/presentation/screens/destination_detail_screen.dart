import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/floating_ai_chat_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../../vr360_audio_guide/presentation/widgets/audio_guide_player_sheet.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';

/// [Ảnh Mẫu 3: Pixel-Perfect] Chi tiết điểm đến phong cách Shangri-La Circle Luxury.
/// 1. Hero photography chiếm 40-45% màn hình với back, gallery counter, share buttons
/// 2. Overlapping White Sheet với bo góc trên 24dp
/// 3. Notice / Announcement banner màu vàng kem nhẹ (loa thông báo + văn bản + chevron)
/// 4. Dòng địa chỉ + Hộp xem trước bản đồ mini bên phải
/// 5. Hàng biểu tượng tiện ích mạ vàng (Dining, Health, Meet, More >)
/// 6. Bộ chọn Ngày tham quan & Số lượng khách
/// 7. Segmented Toggle Pills: Tiêu chuẩn (Standard - vàng kim) vs Gói trải nghiệm (Packages - viền mỏng)
/// 8. Hàng chip lọc (Filters, Loại vé, Thời gian, Giá hội viên)
/// 9. Danh sách thẻ trải nghiệm / vé chi tiết
/// 10. Nút nổi "Trợ lý AI" & Thanh hành động đặt chỗ ở đáy
class DestinationDetailScreen extends StatelessWidget {
  const DestinationDetailScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationDetailCubit>()..load(destinationId),
      child: BlocConsumer<DestinationDetailCubit, DestinationDetailState>(
        listenWhen: (prev, curr) =>
            curr.status.isSuccess &&
            curr.destination != null &&
            prev.destination?.id != curr.destination?.id,
        listener: (context, state) {
          context.read<RecentlyViewedCubit>().add(state.destination!.id);
        },
        builder: (context, state) {
          if (state.status.isLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFFAF7F2),
              body: Center(child: LoadingIndicator()),
            );
          }
          if (state.status.isFailure || state.destination == null) {
            return Scaffold(
              backgroundColor: const Color(0xFFFAF7F2),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'Không tìm thấy điểm đến',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.read<DestinationDetailCubit>().load(destinationId),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return _DetailPixelPerfectView(destination: state.destination!);
        },
      ),
    );
  }
}

class _DetailPixelPerfectView extends StatefulWidget {
  const _DetailPixelPerfectView({required this.destination});

  final Destination destination;

  @override
  State<_DetailPixelPerfectView> createState() => _DetailPixelPerfectViewState();
}

class _DetailPixelPerfectViewState extends State<_DetailPixelPerfectView> {
  int _activeGalleryIndex = 0;
  bool _isStandardSelected = true;
  DateTime _selectedDate = DateTime.now();
  int _adultCount = 1;
  int _childCount = 0;

  Destination get d => widget.destination;

  @override
  Widget build(BuildContext context) {
    final media = d.gallery.isEmpty ? [d.coverImage] : d.gallery;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── 1. Immersive Hero Photography (42% screen height) ─────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image PageView
                      PageView.builder(
                        itemCount: media.length,
                        onPageChanged: (i) => setState(() => _activeGalleryIndex = i),
                        itemBuilder: (_, i) => CoverImage(
                          source: media[i],
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // Top Navigation Icons
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            _HeroIconButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),

                            // Right Action Icons (Gallery counter pill & Share)
                            Row(
                              children: [
                                // Gallery counter pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.photo_library_outlined, size: 14, color: Colors.white),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${_activeGalleryIndex + 1}/${media.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Share Button
                                _HeroIconButton(
                                  icon: Icons.ios_share_rounded,
                                  onTap: () => SocialShareSheet.show(
                                    context,
                                    title: d.name,
                                    message: '${d.name} – ${d.shortDescription}\n📍 ${d.address}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom Overlay Title on Hero
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 30,
                        child: Text(
                          d.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 2)),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Overlapping White Sheet (Sheet with 24dp top radius) ───
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 16,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 2.1 Notice / Announcement Banner ──
                          _buildNoticeBanner(context),

                          const SizedBox(height: 18),

                          // ── 2.2 Address Row with Mini-Map Thumbnail Preview ──
                          _buildAddressAndMiniMapRow(context),

                          const SizedBox(height: 20),

                          // ── 2.3 Amenity Quick Icons Bar (Dining, Health, Meet, More >) ──
                          _buildAmenitiesRow(context),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFEBE7DD)),
                          const SizedBox(height: 16),

                          // ── 2.4 Date Picker Row ──
                          _buildDateSelectorRow(context),

                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFEBE7DD)),
                          const SizedBox(height: 14),

                          // ── 2.5 Guest / Ticket Quantity Row ──
                          _buildGuestQuantityRow(context),

                          const SizedBox(height: 20),

                          // ── 2.6 Segmented Toggle: Standard vs Packages ──
                          _buildSegmentedToggle(),

                          const SizedBox(height: 10),

                          // Subtitle helper text
                          const Text(
                            'Trải nghiệm khám phá thuận tiện với giá niêm yết tiêu chuẩn của ban quản lý di tích.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF70736C),
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── 2.7 Filter Chips Row ──
                          _buildFilterChipsRow(),

                          const SizedBox(height: 18),

                          // ── 2.8 Ticket & Experience Cards ──
                          _buildExperienceCards(context),

                          const SizedBox(height: 24),

                          // ── 2.9 Overview & Cultural History ──
                          _buildOverviewSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 3. Floating AI Assistant Chat Button (Bottom Left) ───────────
          Positioned(
            left: 20,
            bottom: 84,
            child: FloatingAiChatButton(
              label: 'Trợ lý AI',
              onTap: () => context.push(RouteNames.aiChat),
            ),
          ),

          // ── 4. Sticky Bottom Action Bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(context),
          ),
        ],
      ),
    );
  }

  // ── Notice Banner ──────────────────────────────────────────────────────────
  Widget _buildNoticeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.campaign_rounded, color: Color(0xFFD4AF37)),
                SizedBox(width: 8),
                Text('Quy định tham quan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            content: Text(
              'Để đảm bảo an toàn và giữ gìn cảnh quan thiên nhiên tại di tích Ngũ Hành Sơn:\n\n'
              '• Trang phục lịch sự khi vào đền chùa linh thiêng.\n'
              '• Mang giày thể thao chống trơn trượt khi leo núi đá cẩm thạch.\n'
              '• Giờ mở cửa: ${d.openingHours}.\n'
              '• Đội cứu hộ luôn túc trực tại các điểm trọng yếu.',
              style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF4A4D48)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đã hiểu', style: TextStyle(color: Color(0xFF173F35), fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F1), // Pale cream yellow
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFE8D8), width: 1.0),
        ),
        child: const Row(
          children: [
            Icon(Icons.campaign_rounded, size: 20, color: Color(0xFFD4AF37)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'An toàn & quy định tham quan di tích luôn được ưu tiên...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A5D55),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8C8E8A)),
          ],
        ),
      ),
    );
  }

  // ── Address & Mini-Map Row ─────────────────────────────────────────────────
  Widget _buildAddressAndMiniMapRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Address text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF242824),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFB69A67)),
                  const SizedBox(width: 4),
                  Text(
                    '${d.ratingAvg.toStringAsFixed(1)} (${d.reviewCount} đánh giá)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF63665F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Mini-map thumbnail preview box
        GestureDetector(
          onTap: () {
            if (d.latitude != 0.0 && d.longitude != 0.0) {
              MapLauncher.openDirections(
                lat: d.latitude,
                lng: d.longitude,
                label: d.name,
              );
            } else {
              context.push(RouteNames.map);
            }
          },
          child: Container(
            width: 72,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EEDF), // Map soft green
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC8DEC3), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Simulated mini map roads
                CustomPaint(
                  size: const Size(72, 52),
                  painter: _MiniMapRoadsPainter(),
                ),
                // Center Map Pin
                const Center(
                  child: Icon(Icons.location_on_rounded, size: 22, color: Color(0xFFB83A2E)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Amenity Icons Row (Dining, Health, Meet, More >) ──────────────────────
  Widget _buildAmenitiesRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAmenityItem(Icons.restaurant_outlined, 'Ẩm thực', () => context.push(RouteNames.anThuong)),
        _buildAmenityItem(Icons.directions_walk_rounded, 'Khám phá', () {
          if (d.hasVr360) context.push(RouteNames.vr360(d.id));
        }),
        _buildAmenityItem(Icons.headphones_outlined, 'Thuyết minh', () {
          if (d.hasAudioGuide) AudioGuidePlayerSheet.show(context, destinationId: d.id);
        }),
        // More > link
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tiện ích & Dịch vụ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.threesixty_rounded, color: Color(0xFF173F35)),
                      title: const Text('Xem toàn cảnh VR 360°'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.vr360(d.id));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.headphones_rounded, color: Color(0xFF173F35)),
                      title: const Text('Thuyết minh âm thanh đa ngôn ngữ'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        AudioGuidePlayerSheet.show(context, destinationId: d.id);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.elevator_rounded, color: Color(0xFF173F35)),
                      title: const Text('Thang máy kính lên đỉnh Thủy Sơn'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Row(
            children: [
              Text(
                'Xem thêm',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6E67),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF6B6E67)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFFD4AF37)), // Soft Gold
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4D48),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Selector Row ──────────────────────────────────────────────────────
  Widget _buildDateSelectorRow(BuildContext context) {
    final dateStr = '${_selectedDate.day} Th${_selectedDate.month}';
    final nextDateStr = '${_selectedDate.add(const Duration(days: 1)).day} Th${_selectedDate.add(const Duration(days: 1)).month}';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 180)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ngày tham quan',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF70736C),
            ),
          ),
          Row(
            children: [
              Text(
                '$dateStr / $nextDateStr',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242824),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8C8E8A)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Guest Quantity Row ─────────────────────────────────────────────────────
  Widget _buildGuestQuantityRow(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setSheetState) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Chọn số lượng vé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Người lớn (từ 16 tuổi)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _adultCount > 1
                                ? () {
                                    setSheetState(() => _adultCount--);
                                    setState(() {});
                                  }
                                : null,
                          ),
                          Text('$_adultCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setSheetState(() => _adultCount++);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trẻ em / Học sinh', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _childCount > 0
                                ? () {
                                    setSheetState(() => _childCount--);
                                    setState(() {});
                                  }
                                : null,
                          ),
                          Text('$_childCount', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setSheetState(() => _childCount++);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF173F35)),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Số người tham quan',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF70736C),
            ),
          ),
          Row(
            children: [
              Text(
                '$_adultCount Người lớn  $_childCount Trẻ em',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242824),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF8C8E8A)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Segmented Toggle Pills (Standard vs Packages) ──────────────────────────
  Widget _buildSegmentedToggle() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Standard Pill
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isStandardSelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isStandardSelected ? const Color(0xFFE4B85E) : Colors.transparent, // Soft Gold
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isStandardSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFB69A67).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Tiêu chuẩn (Standard)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _isStandardSelected ? const Color(0xFF242824) : const Color(0xFF70736C),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Packages Pill
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isStandardSelected = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isStandardSelected ? const Color(0xFFE4B85E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: !_isStandardSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFB69A67).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Gói trải nghiệm (Packages)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: !_isStandardSelected ? const Color(0xFF242824) : const Color(0xFF70736C),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips Row ───────────────────────────────────────────────────────
  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Filter Icon Chip
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDBD6CA), width: 1.0),
            ),
            child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF242824)),
          ),
          const SizedBox(width: 8),
          _buildFilterChip('Loại vé'),
          const SizedBox(width: 8),
          _buildFilterChip('Khung giờ'),
          const SizedBox(width: 8),
          _buildFilterChip('Giá hội viên'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDBD6CA), width: 1.0),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4D48),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF8C8E8A)),
        ],
      ),
    );
  }

  // ── Ticket & Experience Cards ──────────────────────────────────────────────
  Widget _buildExperienceCards(BuildContext context) {
    if (_isStandardSelected) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE7DD), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: CoverImage(source: d.coverImage, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vé Tham Quan Tiêu Chuẩn – ${d.name}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF242824),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bao gồm quyền vào cổng các hang động, chùa tháp và vãn cảnh di tích.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF70736C)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá vé niêm yết', style: TextStyle(fontSize: 10.5, color: Color(0xFF8C8E8A))),
                    Text(
                      d.ticketInfo.contains('Miễn phí') ? 'Miễn phí vé' : '40.000 VNĐ / vé',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173F35),
                      ),
                    ),
                  ],
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173F35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: () => context.push(RouteNames.bookingForm(d.id)),
                  child: const Text('Đặt vé ngay', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Packages
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEBE7DD), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                height: 160,
                width: double.infinity,
                child: CoverImage(source: 'assets/images/artisan_workshop.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gói Trải Nghiệm Khám Phá Toàn Diện & Làng Đá Mỹ Nghệ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF242824),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bao gồm vé thang máy 2 chiều, vé tham quan di tích, thuyết minh Audio Guide và workshop chạm khắc đá.',
              style: TextStyle(fontSize: 12, color: Color(0xFF70736C)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá trọn gói', style: TextStyle(fontSize: 10.5, color: Color(0xFF8C8E8A))),
                    Text(
                      '350.000 VNĐ / khách',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173F35),
                      ),
                    ),
                  ],
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173F35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: () => context.push(RouteNames.bookingForm(d.id)),
                  child: const Text('Đặt gói trải nghiệm', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // ── Overview & Cultural History ────────────────────────────────────────────
  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TỔNG QUAN & LỊCH SỬ VĂN HÓA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF173F35),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d.overview,
          style: const TextStyle(fontSize: 14, color: Color(0xFF5A5D55), height: 1.6),
        ),
        if (d.culturalHistory.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEBE7DD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Di sản & Tích cổ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF173F35)),
                ),
                const SizedBox(height: 6),
                Text(
                  d.culturalHistory,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B6E67), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Sticky Bottom Bar ──────────────────────────────────────────────────────
  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFEBE7DD), width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favorite button
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBD6CA), width: 1.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.bookmark_border_rounded, size: 22, color: Color(0xFF242824)),
              onPressed: () {
                context.read<FavoritesCubit>().toggle(d.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật danh sách yêu thích')),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          // CTA Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF173F35), // Deep Forest Green
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => context.push(RouteNames.bookingForm(d.id)),
                child: const Text(
                  'Đặt vé tham quan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _MiniMapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFC4D9BD)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.3);
    canvas.drawPath(path, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.4, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
