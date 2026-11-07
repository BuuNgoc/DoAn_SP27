import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../../vr360_audio_guide/presentation/widgets/audio_guide_player_sheet.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';
import '../widgets/destination_widgets.dart';

/// [FE-02] Chi tiết điểm đến – ảnh/video, giờ mở cửa, vị trí, văn hóa lịch sử,
/// lưu yêu thích; lối vào VR360 & Audio Guide (FE-03) và Đánh giá (FE-10).
class DestinationDetailScreen extends StatelessWidget {
  const DestinationDetailScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationDetailCubit>()..load(destinationId),
      child: BlocBuilder<DestinationDetailCubit, DestinationDetailState>(
        builder: (context, state) {
          if (state.status.isLoading) {
            return const TopographicScaffold(appBar: CustomAppBar(title: ''), body: LoadingIndicator());
          }
          if (state.status.isFailure || state.destination == null) {
            return TopographicScaffold(
              appBar: const CustomAppBar(title: ''),
              body: ErrorViewWidget(
                message: state.errorMessage ?? 'Không tìm thấy điểm đến.',
                onRetry: () => context.read<DestinationDetailCubit>().load(destinationId),
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
    final textTheme = Theme.of(context).textTheme;

    return TopographicScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.backgroundIceMint,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: 'Quay lại',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            leadingWidth: 60,
            actions: [
              CircleIconButton(
                icon: Icons.ios_share_rounded,
                tooltip: 'Chia sẻ',
                onPressed: () => SocialShareSheet.show(
                  context,
                  title: d.name,
                  message: '${d.name} – ${d.shortDescription}\n📍 ${d.address}\n#SmartTravel #NguHanhSon',
                ),
              ),
              const SizedBox(width: 8),
              FavoriteButton(destinationId: d.id, size: 42),
              const SizedBox(width: 12),
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
                      child: CoverImage(source: media[i]),
                    ),
                  ),
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x55000000), Colors.transparent, Color(0x66000000)],
                          stops: [0, 0.4, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 18,
                    child: Row(
                      children: [
                        PillBadge(
                          label: '${_page + 1}/${media.length} ảnh',
                          icon: Icons.photo_library_rounded,
                          color: Colors.white,
                          background: Colors.black.withValues(alpha: 0.35),
                        ),
                        if (d.videoCount > 0) ...[
                          const SizedBox(width: 8),
                          PillBadge(
                            label: '${d.videoCount} video',
                            icon: Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            background: Colors.black.withValues(alpha: 0.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PillBadge(label: d.category.label, icon: d.category.icon),
                      for (final t in d.tags.take(2)) PillBadge(label: t, color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(d.name, style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => context.push(RouteNames.destinationReviews(d.id)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          RatingStars(rating: d.ratingAvg, showValue: true),
                          const SizedBox(width: 6),
                          Text(
                            '· ${d.reviewCount} đánh giá',
                            style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (d.hasVr360 || d.hasAudioGuide) ...[
                    _ImmersiveButtons(destination: d),
                    const SizedBox(height: 16),
                  ],
                  _InfoGrid(destination: d),
                  if (d.beachSafetyInfo != null) ...[
                    const SizedBox(height: 16),
                    _SafetyNotice(text: d.beachSafetyInfo!),
                  ],
                  const SizedBox(height: 24),
                  Text('Giới thiệu', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(d.overview, style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.55)),
                  if (d.highlights.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final h in d.highlights)
                          Chip(
                            avatar: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                            label: Text(h),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _CultureCard(text: d.culturalHistory),
                  const SizedBox(height: 24),
                  Text('Vị trí', style: textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _LocationCard(destination: d),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Text('Đánh giá từ du khách', style: textTheme.titleLarge)),
                      TextButton(
                        onPressed: () => context.push(RouteNames.destinationReviews(d.id)),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () => context.push(RouteNames.writeReview(d.id)),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Viết đánh giá của bạn'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
                  const SizedBox(height: 40),
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

/// Hai nút nổi bật mở VR360 (chỉ khi `hasVr360 == true`) và Audio Guide.
class _ImmersiveButtons extends StatelessWidget {
  const _ImmersiveButtons({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (destination.hasVr360)
          Expanded(
            child: CustomButton(
              label: 'Xem VR360',
              icon: Icons.threesixty_rounded,
              onPressed: () => context.push(RouteNames.vr360(destination.id)),
            ),
          ),
        if (destination.hasVr360 && destination.hasAudioGuide) const SizedBox(width: 12),
        if (destination.hasAudioGuide)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => AudioGuidePlayerSheet.show(context, destinationId: destination.id),
              icon: const Icon(Icons.headphones_rounded),
              label: const Text('Nghe thuyết minh'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: AppColors.surfaceWhite,
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final hours = destination.visitDurationMinutes ~/ 60;
    final minutes = destination.visitDurationMinutes % 60;
    final duration = hours == 0 ? '$minutes phút' : (minutes == 0 ? '$hours giờ' : '$hours giờ $minutes phút');
    return AppCard(
      child: Column(
        children: [
          _InfoRow(icon: Icons.schedule_rounded, label: 'Giờ mở cửa', value: destination.openingHours),
          const Divider(height: 22),
          _InfoRow(icon: Icons.confirmation_number_outlined, label: 'Giá vé', value: destination.ticketInfo),
          const Divider(height: 22),
          _InfoRow(icon: Icons.timelapse_rounded, label: 'Thời gian tham quan gợi ý', value: duration),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

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
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lưu ý an toàn bãi biển', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
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
    return AppCard(
      color: AppColors.backgroundSecondary,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_rounded, color: AppColors.accentSoftGold),
              SizedBox(width: 8),
              Text('Văn hóa & Lịch sử', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
            child: Text(_expanded ? 'Thu gọn' : 'Đọc thêm'),
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(destination.address, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tọa độ: ${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.map),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Xem bản đồ'),
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
                      showAppSnackBar(context, 'Không mở được ứng dụng bản đồ.', type: SnackType.error);
                    }
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Chỉ đường'),
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
