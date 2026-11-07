import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
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
        appBar: const CustomAppBar(title: 'Nghệ nhân làng đá', subtitle: 'Làng đá mỹ nghệ Non Nước'),
        body: BlocBuilder<ArtisanCubit, DetailState<ArtisanProfile>>(
          builder: (context, state) {
            if (state.status.isFailure) {
              return ErrorViewWidget(
                message: state.errorMessage ?? 'Không tải được hồ sơ.',
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
                          _Stat(value: '${a.yearsOfExperience}', label: 'Năm kinh nghiệm'),
                          _Stat(value: a.rating.toStringAsFixed(1), label: 'Đánh giá'),
                          _Stat(value: '${a.featuredWorks.length}', label: 'Tác phẩm tiêu biểu'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PillBadge(label: a.specialty, icon: Icons.auto_fix_high_rounded, color: AppColors.accentSoftGold),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Câu chuyện nghệ nhân'),
                const SizedBox(height: 8),
                Text(a.bio, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: 20),
                AppCard(
                  color: AppColors.backgroundSecondary,
                  showShadow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history_edu_rounded, color: AppColors.accentSoftGold),
                          SizedBox(width: 8),
                          Text('Lịch sử nghề điêu khắc đá Non Nước',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(a.craftHistory, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                    ],
                  ),
                ),
                if (a.featuredWorks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Tác phẩm tiêu biểu'),
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
                  const SectionHeader(title: 'Giải thưởng'),
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
                const SectionHeader(title: 'Đăng ký học thử', subtitle: 'Workshop do nghệ nhân trực tiếp hướng dẫn'),
                const SizedBox(height: 10),
                if (profile.workshops.isEmpty)
                  const Text('Hiện chưa có lịch workshop. Vui lòng quay lại sau.',
                      style: TextStyle(color: AppColors.textMuted))
                else
                  for (final w in profile.workshops) ...[
                    EventCard(event: w),
                    const SizedBox(height: 10),
                    CustomButton(
                      label: w.isFull ? 'Đã kín chỗ' : 'Đăng ký học thử',
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
