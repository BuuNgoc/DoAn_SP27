import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/tourism_components.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../../vr360_audio_guide/presentation/widgets/audio_guide_player_sheet.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [Redesign Shangri-La Destination Guide] Chi tiết điểm đến cao cấp.
/// Bao gồm:
/// - Large immersive image gallery
/// - Tên địa điểm, Location, Rating với Soft Gold
/// - Highlights, Giờ mở cửa & Chi phí
/// - Things to do & Di sản văn hóa lịch sử
/// - Sticky bottom bar: "Thêm vào hành trình"
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
              backgroundColor: AppColors.background,
              appBar: CustomAppBar(title: ''),
              body: LoadingIndicator(),
            );
          }
          if (state.status.isFailure || state.destination == null) {
            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: const CustomAppBar(title: ''),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage ?? 'Không tìm thấy điểm đến', style: const TextStyle(color: AppColors.error)),
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
          return _DetailView(destination: state.destination!);
        },
      ),
    );
  }
}

class _DetailView extends StatefulWidget {
  const _DetailView({required this.destination});

  final Destination destination;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  int _page = 0;

  Destination get d => widget.destination;

  @override
  Widget build(BuildContext context) {
    final media = d.gallery.isEmpty ? [d.coverImage] : d.gallery;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── 1. Large Immersive Gallery AppBar ───────────────────────────
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _DetailCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: 'Quay lại',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                leadingWidth: 56,
                actions: [
                  _DetailCircleButton(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Chia sẻ',
                    onTap: () => SocialShareSheet.show(
                      context,
                      title: d.name,
                      message: '${d.name} – ${d.shortDescription}\n📍 ${d.address}\n#SmartTravel #NguHanhSon',
                    ),
                  ),
                  const SizedBox(width: 8),
                  FavoriteButton(destinationId: d.id, size: 40),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: media.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, i) => GestureDetector(
                          onTap: () => _openGallery(context, media, i),
                          child: CoverImage(source: media[i], fit: BoxFit.cover),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x66000000), Colors.transparent, Color(0x99173F35)],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      // Gallery Page Indicator
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_rounded, size: 12, color: AppColors.softGold),
                              const SizedBox(width: 6),
                              Text(
                                '${_page + 1} / ${media.length} ẢNH',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Destination Information & Editorial Sections ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.8),
                        ),
                        child: Text(
                          d.category.label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        d.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Location & Rating
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: AppColors.softGold),
                          const SizedBox(width: 4),
                          Text(
                            d.ratingAvg.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => context.push(RouteNames.destinationReviews(d.id)),
                            child: Text(
                              '(${d.reviewCount} đánh giá)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 10),
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              d.address,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Immersive VR360 & Audio buttons
                      if (d.hasVr360 || d.hasAudioGuide) ...[
                        Row(
                          children: [
                            if (d.hasVr360)
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => context.push(RouteNames.vr360(d.id)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                                    ),
                                  ),
                                  icon: const Icon(Icons.threesixty_rounded, size: 18),
                                  label: const Text('Xem VR 360°', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                            if (d.hasVr360 && d.hasAudioGuide) const SizedBox(width: 12),
                            if (d.hasAudioGuide)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => AudioGuidePlayerSheet.show(context, destinationId: d.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                                    ),
                                  ),
                                  icon: const Icon(Icons.headphones_rounded, size: 18),
                                  label: const Text('Thuyết minh Audio', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Highlights Section
                      if (d.highlights.isNotEmpty) ...[
                        const Text(
                          'ĐIỂM NỔI BẬT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final h in d.highlights)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      h,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Overview
                      const Text(
                        'TỔNG QUAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d.overview,
                        style: const TextStyle(fontSize: 14.5, color: AppColors.textSecondary, height: 1.6),
                      ),

                      const SizedBox(height: 24),

                      // Opening hours & Details Card
                      TourismCard(
                        padding: const EdgeInsets.all(AppDimensions.s16),
                        child: Column(
                          children: [
                            _DetailInfoRow(
                              icon: Icons.schedule_rounded,
                              label: 'Giờ mở cửa',
                              value: d.openingHours,
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            _DetailInfoRow(
                              icon: Icons.confirmation_number_outlined,
                              label: 'Vé tham quan',
                              value: d.ticketInfo,
                            ),
                            const Divider(height: 24, color: AppColors.border),
                            _DetailInfoRow(
                              icon: Icons.timelapse_rounded,
                              label: 'Thời gian tham quan gợi ý',
                              value: '${d.visitDurationMinutes} phút',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cultural History Card
                      _CultureCard(text: d.culturalHistory),

                      const SizedBox(height: 24),

                      // Map & Directions
                      const Text(
                        'VỊ TRÍ & ĐỊA ĐIỂM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LocationCard(destination: d),

                      const SizedBox(height: 24),

                      // Reviews Header & Write Review
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ĐÁNH GIÁ TỪ DU KHÁCH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.destinationReviews(d.id)),
                            child: const Text('Xem tất cả', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: () => context.push(RouteNames.writeReview(d.id)),
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text('Viết đánh giá của bạn', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 3. Sticky Bottom Action Bar ─────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.98),
                border: const Border(top: BorderSide(color: AppColors.border, width: 1.0)),
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
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final saved = context.read<FavoritesCubit>().state.contains(d.id);
                        if (!saved) {
                          await context.read<FavoritesCubit>().toggle(d.id);
                        }
                        if (context.mounted) {
                          showAppSnackBar(
                            context,
                            'Đã thêm "${d.name}" vào Hành trình của bạn.',
                            type: SnackType.success,
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                        ),
                      ),
                      icon: const Icon(Icons.luggage_rounded, size: 18),
                      label: const Text(
                        'Thêm vào hành trình',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openGallery(BuildContext context, List<String> media, int initial) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _GalleryViewer(images: media, initialIndex: initial, title: d.name),
      ),
    );
  }
}

class _DetailCircleButton extends StatelessWidget {
  const _DetailCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CultureCard extends StatefulWidget {
  const _CultureCard({required this.text});

  final String text;

  @override
  State<_CultureCard> createState() => _CultureCardState();
}

class _CultureCardState extends State<_CultureCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_rounded, color: AppColors.softGold, size: 20),
              SizedBox(width: 8),
              Text(
                'VĂN HÓA & LỊCH SỬ',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              widget.text,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.55),
            ),
            secondChild: Text(widget.text, style: const TextStyle(color: AppColors.textSecondary, height: 1.55)),
          ),
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              _expanded ? 'Thu gọn' : 'Đọc thêm chi tiết',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  destination.address,
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.map),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Xem bản đồ', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final ok = await MapLauncher.openDirections(
                      lat: destination.latitude,
                      lng: destination.longitude,
                    );
                    if (!ok && context.mounted) {
                      showAppSnackBar(context, 'Không thể mở ứng dụng bản đồ', type: SnackType.error);
                    }
                  },
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: const Text('Chỉ đường', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GalleryViewer extends StatelessWidget {
  const _GalleryViewer({required this.images, required this.initialIndex, required this.title});

  final List<String> images;
  final int initialIndex;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (_, i) => InteractiveViewer(
          maxScale: 4,
          child: Center(child: CoverImage(source: images[i], fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
