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
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../domain/entities/map_poi.dart';
import '../bloc/map_cubit.dart';
import '../widgets/map_canvas.dart';

/// [FE-04] Bản đồ tương tác Ngũ Hành Sơn – lọc lớp, xem nhanh, chỉ đường.
class InteractiveMapScreen extends StatelessWidget {
  const InteractiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapCubit>()..load(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final _controller = TransformationController();
  static const _projection = MapProjection();
  Size? _viewport;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _focus(double lat, double lng, {double scale = 0.75}) {
    final viewport = _viewport;
    if (viewport == null) return;
    final p = _projection.toCanvas(lat, lng);
    final tx = viewport.width / 2 - p.dx * scale;
    final ty = viewport.height / 2 - p.dy * scale;
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
  }

  void _resetView() => _focus(16.0060, 108.2600, scale: 0.62);

  Future<void> _openPoi(BuildContext context, MapPoi poi) async {
    final cubit = context.read<MapCubit>()..select(poi);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PoiQuickViewSheet(poi: poi),
    );
    cubit.clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return TopographicScaffold(
      appBar: CustomAppBar(
        title: 'Bản đồ Ngũ Hành Sơn',
        subtitle: 'Chạm vào ghim để xem nhanh địa điểm',
        showBackButton: false,
        actions: [
          CircleIconButton(icon: Icons.center_focus_strong_rounded, tooltip: 'Về trung tâm', onPressed: _resetView),
        ],
      ),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state.status.isFailure && state.pois.isEmpty) {
            return ErrorViewWidget(
              message: state.errorMessage ?? 'Không tải được bản đồ.',
              onRetry: context.read<MapCubit>().load,
            );
          }
          return Column(
            children: [
              _LayerChips(state: state),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, AppDimensions.bottomNavClearance - 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final first = _viewport == null;
                          _viewport = constraints.biggest;
                          if (first) WidgetsBinding.instance.addPostFrameCallback((_) => _resetView());
                          return Stack(
                            children: [
                              InteractiveViewer(
                                transformationController: _controller,
                                constrained: false,
                                minScale: 0.35,
                                maxScale: 2.5,
                                boundaryMargin: const EdgeInsets.all(120),
                                child: SizedBox.fromSize(
                                  size: MapProjection.canvasSize,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Positioned.fill(child: CustomPaint(painter: NguHanhSonMapPainter())),
                                      for (final poi in state.visiblePois) _positionedPin(context, state, poi),
                                    ],
                                  ),
                                ),
                              ),
                              if (state.status.isLoading)
                                const Positioned(
                                  top: 12,
                                  right: 12,
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                ),
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: PillBadge(
                                  label: '${state.visiblePois.length} địa điểm đang hiển thị',
                                  icon: Icons.place_rounded,
                                  background: AppColors.surfaceWhite.withValues(alpha: 0.92),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Column(
                                  children: [
                                    CircleIconButton(
                                      icon: Icons.add_rounded,
                                      tooltip: 'Phóng to',
                                      onPressed: () => _zoom(1.3),
                                    ),
                                    const SizedBox(height: 8),
                                    CircleIconButton(
                                      icon: Icons.remove_rounded,
                                      tooltip: 'Thu nhỏ',
                                      onPressed: () => _zoom(1 / 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _zoom(double factor) {
    final viewport = _viewport;
    if (viewport == null) return;
    final m = _controller.value.clone();
    final scale = (m.getMaxScaleOnAxis() * factor).clamp(0.35, 2.5);
    final center = Offset(viewport.width / 2, viewport.height / 2);
    final scene = _controller.toScene(center);
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, center.dx - scene.dx * scale)
      ..setEntry(1, 3, center.dy - scene.dy * scale);
  }

  Widget _positionedPin(BuildContext context, MapState state, MapPoi poi) {
    final p = _projection.toCanvas(poi.latitude, poi.longitude);
    return Positioned(
      left: p.dx - MapPin.width / 2,
      top: p.dy - MapPin.height,
      child: MapPin(
        poi: poi,
        selected: state.selected?.id == poi.id,
        onTap: () => _openPoi(context, poi),
      ),
    );
  }
}

class _LayerChips extends StatelessWidget {
  const _LayerChips({required this.state});

  final MapState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapCubit>();
    final allOn = state.activeLayers.length == MapLayer.values.length;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('Tất cả'),
            selected: allOn,
            onSelected: (_) => cubit.showAll(),
          ),
          for (final layer in MapLayer.values) ...[
            const SizedBox(width: 8),
            FilterChip(
              avatar: Icon(layer.icon, size: 16, color: state.activeLayers.contains(layer) ? Colors.white : layer.color),
              label: Text('${layer.label} (${state.countOf(layer)})'),
              selected: state.activeLayers.contains(layer),
              showCheckmark: false,
              selectedColor: layer.color,
              labelStyle: TextStyle(
                color: state.activeLayers.contains(layer) ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => cubit.toggleLayer(layer),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet xem nhanh địa điểm + nút Chỉ đường.
class PoiQuickViewSheet extends StatelessWidget {
  const PoiQuickViewSheet({super.key, required this.poi});

  final MapPoi poi;

  @override
  Widget build(BuildContext context) {
    final detailRoute = poi.destinationId != null
        ? RouteNames.destinationDetail(poi.destinationId!)
        : (poi.eventId != null ? RouteNames.eventDetail(poi.eventId!) : null);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusSheet)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (poi.image != null) ...[
                CoverImage(source: poi.image!, width: 86, height: 86, radius: 16),
                const SizedBox(width: 14),
              ] else ...[
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: poi.layer.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(poi.layer.icon, color: poi.layer.color, size: 30),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PillBadge(label: poi.layer.label, icon: poi.layer.icon, color: poi.layer.color),
                    const SizedBox(height: 6),
                    Text(poi.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    if (poi.rating != null) ...[
                      const SizedBox(height: 4),
                      RatingStars(rating: poi.rating!, size: 15, showValue: true),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(poi.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          _line(Icons.place_outlined, poi.address),
          if (poi.openingHours != null) _line(Icons.schedule_rounded, poi.openingHours!),
          if (poi.priceHint != null) _line(Icons.payments_outlined, poi.priceHint!),
          const SizedBox(height: 16),
          Row(
            children: [
              if (detailRoute != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(detailRoute);
                    },
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text('Xem chi tiết'),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final ok = await MapLauncher.openDirections(lat: poi.latitude, lng: poi.longitude);
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

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryTeal),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
          ],
        ),
      );
}
