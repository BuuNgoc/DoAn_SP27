import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../events_workshops_craft/presentation/widgets/event_widgets.dart';
import '../../domain/entities/zone_entities.dart';
import '../bloc/zone_cubits.dart';
import '../widgets/zone_widgets.dart';
import 'an_thuong_experience_hub_screen.dart';

/// [FE-13] Du lịch biển Sơn Thủy – Tân Trà – Non Nước.
class BeachTourismScreen extends StatelessWidget {
  const BeachTourismScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ZoneCubit>()..load(ZoneType.beach),
      child: TopographicScaffold(
        seed: 79,
        body: BlocBuilder<ZoneCubit, ZoneState>(
          builder: (context, state) {
            if (state.status.isLoading) return LoadingIndicator(message: context.tr('zones.loading_beach'));
            if (state.status.isFailure || state.overview == null) {
              return ErrorViewWidget(
                message: state.errorMessage ?? context.tr('common.load_error'),
                onRetry: () => context.read<ZoneCubit>().load(ZoneType.beach),
              );
            }
            final o = state.overview!;
            return CustomScrollView(
              slivers: [
                ZoneSliverHeader(overview: o),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  sliver: SliverList.list(
                    children: [
                      if (o.safety != null) BeachSafetyCard(info: o.safety!),
                      const SizedBox(height: 20),
                      Text(o.introduction, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: context.tr('zones.beaches_title'),
                        subtitle: context.tr('zones.beaches_subtitle'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 268,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: o.beaches.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => _BeachCard(beach: o.beaches[i]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: context.tr('zones.activities_services_title'),
                        subtitle: context.tr('zones.activities_services_sub'),
                      ),
                      const SizedBox(height: 10),
                      ZoneCategoryChips(state: state),
                      const SizedBox(height: 12),
                      for (final s in state.visibleSpots) ...[ZoneSpotCard(spot: s), const SizedBox(height: 12)],
                      const SizedBox(height: 12),
                      SectionHeader(
                        title: context.tr('zones.coastline_map'),
                        actionLabel: context.tr('zones.full_map'),
                        onAction: () => context.go(RouteNames.map),
                      ),
                      const SizedBox(height: 10),
                      ZoneMiniMap(spots: o.spots, showSea: true),
                      if (state.events.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(title: context.tr('zones.beach_events')),
                        const SizedBox(height: 10),
                        for (final e in state.events) ...[EventCard(event: e), const SizedBox(height: 12)],
                      ],
                      const SizedBox(height: 12),
                      ZoneTipsCard(tips: o.tips, title: context.tr('zones.beach_tips_title')),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Thẻ "Cảnh báo an toàn bãi biển" nổi bật.
class BeachSafetyCard extends StatefulWidget {
  const BeachSafetyCard({super.key, required this.info});
  final BeachSafetyInfo info;

  @override
  State<BeachSafetyCard> createState() => _BeachSafetyCardState();
}

class _BeachSafetyCardState extends State<BeachSafetyCard> {
  bool _expanded = false;

  Future<void> _call(String phone) async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));
    if (!ok && mounted) {
      showAppSnackBar(
        context,
        context.tr('zones.call_error', params: {'phone': phone}),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final level = info.overallLevel;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: level.color.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [BoxShadow(color: level.color.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: level.color,
                  child: Icon(level.icon, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('zones.beach_safety_header'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(level.label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: level.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info.headline, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.45)),
                const SizedBox(height: 4),
                Text(
                  context.tr('zones.updated_by_board', params: {'time': DateFormatter.relative(info.updatedAt)}),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Condition(icon: Icons.waves_rounded, label: context.tr('zones.condition_waves'), value: info.waveHeight),
                    _Condition(icon: Icons.air_rounded, label: context.tr('zones.condition_wind'), value: info.windSpeed),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Condition(icon: Icons.thermostat_rounded, label: context.tr('zones.condition_water_temp'), value: info.waterTemperature),
                    _Condition(icon: Icons.wb_sunny_rounded, label: context.tr('zones.condition_uv'), value: info.uvIndex),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final l in SafetyLevel.values)
                      PillBadge(label: l.label, color: l.color, solid: l == level, fontSize: 10.5),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('zones.safety_rules_title'), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        for (final t in info.tips)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 16, color: level.color),
                                const SizedBox(width: 8),
                                Expanded(child: Text(t, style: const TextStyle(height: 1.45, fontSize: 13.5))),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(context.tr('zones.emergency_phones_title'), style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        for (final c in info.contacts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Icon(c.icon, color: AppColors.error),
                            title: Text(c.label),
                            trailing: TextButton.icon(
                              onPressed: () => _call(c.phone),
                              icon: const Icon(Icons.call_rounded, size: 18),
                              label: Text(c.phone, style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
              label: Text(_expanded ? context.tr('common.collapse') : context.tr('zones.safety_and_emergency_btn')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Condition extends StatelessWidget {
  const _Condition({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.backgroundSecondary, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: AppColors.primaryTeal),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeachCard extends StatelessWidget {
  const _BeachCard({required this.beach});
  final BeachArea beach;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: beach.destinationId == null ? null : () => context.push(RouteNames.destinationDetail(beach.destinationId!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: CoverImage(source: beach.image, height: 120, width: 250, radius: 0),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: PillBadge(
                    label: beach.safetyLevel.label,
                    icon: beach.safetyLevel.icon,
                    color: beach.safetyLevel.color,
                    solid: true,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(beach.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(beach.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.support_rounded, size: 15, color: AppColors.primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('zones.lifeguard_hours', params: {'hours': beach.lifeguardHours}),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(beach.facilities.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
