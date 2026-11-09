import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../domain/entities/vr360_audio_entities.dart';
import '../bloc/vr360_audio_cubits.dart';
import '../widgets/audio_guide_player_sheet.dart';

/// [FE-03] Trải nghiệm VR360 toàn màn hình: xoay đa chiều, chọn góc nhìn,
/// chạm hotspot để xem nội dung theo vị trí.
class Vr360PanoramaScreen extends StatelessWidget {
  const Vr360PanoramaScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<Vr360Cubit>()..load(destinationId),
      child: BlocBuilder<Vr360Cubit, Vr360State>(
        builder: (context, state) {
          if (state.status.isFailure || (state.status.isSuccess && state.scenes.isEmpty)) {
            return TopographicScaffold(
              appBar: CustomAppBar(title: context.tr('vr360.title')),
              body: state.status.isFailure
                  ? ErrorViewWidget(
                      message: state.errorMessage ?? context.tr('vr360.load_error'),
                      onRetry: () => context.read<Vr360Cubit>().load(destinationId),
                    )
                  : EmptyStateWidget(
                      icon: Icons.threesixty_rounded,
                      title: context.tr('vr360.empty_title'),
                      message: context.tr('vr360.empty_message'),
                    ),
            );
          }
          if (state.currentScene == null) {
            return const Scaffold(backgroundColor: Colors.black, body: LoadingIndicator());
          }
          return _PanoramaView(destinationId: destinationId, state: state);
        },
      ),
    );
  }
}

class _PanoramaView extends StatelessWidget {
  const _PanoramaView({required this.destinationId, required this.state});

  final String destinationId;
  final Vr360State state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<Vr360Cubit>();
    final scene = state.currentScene!;
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PanoramaViewer(
              key: ValueKey(scene.id),
              longitude: scene.initialLongitude,
              animSpeed: state.gyroEnabled ? 0 : 0.6,
              sensorControl: state.gyroEnabled ? SensorControl.orientation : SensorControl.none,
              minLatitude: -60,
              maxLatitude: 60,
              onTap: (_, _, _) => cubit.dismissHotspot(),
              hotspots: [
                for (final h in scene.hotspots)
                  Hotspot(
                    latitude: h.latitude,
                    longitude: h.longitude,
                    width: 140,
                    height: 70,
                    widget: _HotspotMarker(hotspot: h, onTap: () => cubit.tapHotspot(h)),
                  ),
              ],
              child: Image.asset(scene.panoramaImage),
            ),
          ),
          // Thanh trên cùng
          Positioned(
            top: topPad + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.close_rounded,
                  tooltip: context.tr('common.close'),
                  background: Colors.black.withValues(alpha: 0.4),
                  color: Colors.white,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(scene.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        Text(scene.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleIconButton(
                  icon: state.gyroEnabled ? Icons.screen_rotation_rounded : Icons.touch_app_rounded,
                  tooltip: state.gyroEnabled ? context.tr('vr360.gyro_on_tooltip') : context.tr('vr360.gyro_off_tooltip'),
                  background: state.gyroEnabled ? AppColors.primaryTeal : Colors.black.withValues(alpha: 0.4),
                  color: Colors.white,
                  onPressed: cubit.toggleGyro,
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.headphones_rounded,
                  tooltip: context.tr('destinations.listen_audio_guide'),
                  background: Colors.black.withValues(alpha: 0.4),
                  color: Colors.white,
                  onPressed: () => AudioGuidePlayerSheet.show(context, destinationId: destinationId),
                ),
              ],
            ),
          ),
          // Thẻ thông tin hotspot
          if (state.selectedHotspot != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 150,
              child: _HotspotInfoCard(
                hotspot: state.selectedHotspot!,
                onClose: cubit.dismissHotspot,
                onFollow: () => cubit.followHotspot(state.selectedHotspot!),
              ),
            ),
          // Chọn góc nhìn
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 14, 16, MediaQuery.paddingOf(context).bottom + 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.tr('vr360.choose_viewpoint'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.scenes.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final s = state.scenes[i];
                        final selected = i == state.currentIndex;
                        return GestureDetector(
                          onTap: () => cubit.selectScene(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? AppColors.primaryPastel : Colors.white24,
                                width: selected ? 2.5 : 1,
                              ),
                              image: DecorationImage(
                                image: AssetImage(s.panoramaImage),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: selected ? 0.2 : 0.5),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              s.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('vr360.gesture_hint'),
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotMarker extends StatelessWidget {
  const _HotspotMarker({required this.hotspot, required this.onTap});

  final Vr360Hotspot hotspot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLink = hotspot.targetSceneId != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (isLink ? AppColors.accentSoftGold : AppColors.primaryPastel).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
            ),
            child: Icon(isLink ? Icons.double_arrow_rounded : Icons.info_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hotspot.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotInfoCard extends StatelessWidget {
  const _HotspotInfoCard({required this.hotspot, required this.onClose, required this.onFollow});

  final Vr360Hotspot hotspot;
  final VoidCallback onClose;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.place_rounded, color: AppColors.primaryTeal, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(hotspot.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded), tooltip: context.tr('common.close')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(hotspot.description,
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontSize: 13.5)),
            ),
            if (hotspot.targetSceneId != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onFollow,
                icon: const Icon(Icons.double_arrow_rounded, size: 18),
                label: Text(context.tr('vr360.move_to_viewpoint')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
