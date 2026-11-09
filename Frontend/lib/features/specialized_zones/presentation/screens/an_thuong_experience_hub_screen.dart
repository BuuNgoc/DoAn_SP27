import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../events_workshops_craft/presentation/widgets/event_widgets.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/zone_entities.dart';
import '../bloc/zone_cubits.dart';
import '../widgets/zone_widgets.dart';

/// [FE-12] Trung tâm trải nghiệm phố Tây An Thượng.
class AnThuongExperienceHubScreen extends StatelessWidget {
  const AnThuongExperienceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ZoneCubit>()..load(ZoneType.anThuong),
      child: TopographicScaffold(
        seed: 73,
        body: BlocBuilder<ZoneCubit, ZoneState>(
          builder: (context, state) {
            if (state.status.isLoading) return LoadingIndicator(message: context.tr('zones.loading_an_thuong'));
            if (state.status.isFailure || state.overview == null) {
              return ErrorViewWidget(
                message: state.errorMessage ?? context.tr('common.load_error'),
                onRetry: () => context.read<ZoneCubit>().load(ZoneType.anThuong),
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
                      Text(o.introduction, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      const _NightlifeBanner(),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: context.tr('zones.what_to_eat_play'),
                        subtitle: context.tr('zones.what_to_eat_play_sub'),
                      ),
                      const SizedBox(height: 10),
                      ZoneCategoryChips(state: state),
                      const SizedBox(height: 12),
                      for (final s in state.visibleSpots) ...[ZoneSpotCard(spot: s), const SizedBox(height: 12)],
                      const SizedBox(height: 12),
                      SectionHeader(
                        title: context.tr('zones.neighborhood_map'),
                        subtitle: context.tr('zones.tap_pin_for_details'),
                        actionLabel: context.tr('zones.full_map'),
                        onAction: () => context.go(RouteNames.map),
                      ),
                      const SizedBox(height: 10),
                      ZoneMiniMap(spots: o.spots),
                      if (state.events.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(
                          title: context.tr('zones.events_in_an_thuong'),
                          actionLabel: context.tr('common.all'),
                          onAction: () => context.push(RouteNames.events),
                        ),
                        const SizedBox(height: 10),
                        for (final e in state.events) ...[EventCard(event: e), const SizedBox(height: 12)],
                      ],
                      const SizedBox(height: 12),
                      ZoneTipsCard(tips: o.tips),
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

class _NightlifeBanner extends StatelessWidget {
  const _NightlifeBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(colors: [Color(0xFF24838B), Color(0xFF6E6BC9)]),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.nightlife_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('zones.nightlife_banner_title'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  context.tr('zones.nightlife_banner_desc'),
                  style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// SliverAppBar dùng chung cho các trang phân khu.
class ZoneSliverHeader extends StatelessWidget {
  const ZoneSliverHeader({super.key, required this.overview});
  final ZoneOverview overview;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.backgroundIceMint,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: context.tr('common.back'),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      actions: [
        CircleIconButton(
          icon: Icons.ios_share_rounded,
          tooltip: context.tr('common.share'),
          onPressed: () => SocialShareSheet.show(
            context,
            title: overview.title,
            message: context.tr(
              'zones.share_zone_message',
              params: {'title': overview.title, 'tagline': overview.tagline},
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ZoneHeroBackground(image: overview.heroImage, title: overview.title, tagline: overview.tagline),
      ),
    );
  }
}

class ZoneCategoryChips extends StatelessWidget {
  const ZoneCategoryChips({super.key, required this.state});
  final ZoneState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(context.tr('common.all')),
              selected: state.category == null,
              onSelected: (_) => context.read<ZoneCubit>().selectCategory(null),
            ),
          ),
          for (final c in state.categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(c.icon, size: 16),
                label: Text(c.label),
                selected: state.category == c,
                onSelected: (_) => context.read<ZoneCubit>().selectCategory(c),
              ),
            ),
        ],
      ),
    );
  }
}

class ZoneTipsCard extends StatelessWidget {
  const ZoneTipsCard({super.key, required this.tips, this.title});
  final List<String> tips;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();
    final effectiveTitle = title ?? context.tr('zones.traveler_tips_title');
    return AppCard(
      color: AppColors.backgroundSecondary,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.accentSoftGold),
              const SizedBox(width: 8),
              Text(effectiveTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w800)),
                  Expanded(child: Text(t, style: const TextStyle(height: 1.45, fontSize: 13.5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
