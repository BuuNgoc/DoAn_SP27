import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/events_cubits.dart';
import '../widgets/event_widgets.dart';

/// [FE-15] Hồ sơ nghệ nhân Làng đá Non Nước, lịch sử nghề và đăng ký học thử.
class CraftWorkshopArtisanScreen extends StatelessWidget {
  const CraftWorkshopArtisanScreen({super.key, required this.artisanId});

  final String artisanId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArtisanCubit>()..load(artisanId),
      child: TopographicScaffold(
        seed: 21,
        appBar: CustomAppBar(
          title: context.tr('artisan.title'),
          subtitle: context.tr('artisan.subtitle'),
        ),
        body: BlocBuilder<ArtisanCubit, DetailState<ArtisanProfile>>(
          builder: (context, state) {
            if (state.status.isFailure) {
              return ErrorViewWidget(
                message: state.errorMessage ?? context.tr('artisan.load_error'),
                onRetry: () => context.read<ArtisanCubit>().load(artisanId),
              );
            }
            final profile = state.data;
            if (profile == null) return const LoadingIndicator();
            final a = profile.artisan;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(gradient: AppColors.goldGradient, shape: BoxShape.circle),
                        child: CircleAvatar(radius: 52, backgroundImage: AssetImage(a.avatar)),
                      ),
                      const SizedBox(height: 12),
                      Text(a.name, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(a.title,
                          textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _Stat(value: '${a.yearsOfExperience}', label: context.tr('artisan.years_experience')),
                          _Stat(value: a.rating.toStringAsFixed(1), label: context.tr('artisan.rating')),
                          _Stat(value: '${a.featuredWorks.length}', label: context.tr('artisan.featured_works')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PillBadge(label: a.specialty, icon: Icons.auto_fix_high_rounded, color: AppColors.accentSoftGold),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(title: context.tr('artisan.story_title')),
                const SizedBox(height: 8),
                Text(a.bio, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: 20),
                AppCard(
                  color: AppColors.backgroundSecondary,
                  showShadow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_edu_rounded, color: AppColors.accentSoftGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.tr('artisan.craft_history_title'),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(a.craftHistory, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                    ],
                  ),
                ),
                if (a.featuredWorks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  SectionHeader(title: context.tr('artisan.featured_works')),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: a.featuredWorks.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final w = a.featuredWorks[i];
                        return SizedBox(
                          width: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CoverImage(source: w.image, width: 160, height: 130, radius: 16),
                              const SizedBox(height: 6),
                              Text(w.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(w.material, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (a.awards.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeader(title: context.tr('artisan.awards_title')),
                  const SizedBox(height: 6),
                  for (final aw in a.awards)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.emoji_events_rounded, color: AppColors.accentSoftGold),
                      title: Text(aw),
                    ),
                ],
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: AppColors.primaryTeal),
                      const SizedBox(width: 10),
                      Expanded(child: Text(a.workshopAddress, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: context.tr('artisan.trial_class_title'),
                  subtitle: context.tr('artisan.trial_class_subtitle'),
                ),
                const SizedBox(height: 10),
                if (profile.workshops.isEmpty)
                  Text(context.tr('artisan.no_workshops'), style: const TextStyle(color: AppColors.textMuted))
                else
                  for (final w in profile.workshops) ...[
                    EventCard(event: w),
                    const SizedBox(height: 10),
                    CustomButton(
                      label: w.isFull ? context.tr('events.capacity_full') : context.tr('artisan.trial_class_title'),
                      icon: Icons.handyman_rounded,
                      onPressed: w.isFull ? null : () => context.push(RouteNames.bookingForm(w.id)),
                    ),
                    const SizedBox(height: 16),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
