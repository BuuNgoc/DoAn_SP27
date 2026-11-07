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
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../destination_discovery/presentation/widgets/destination_widgets.dart';
import '../../../events_workshops_craft/presentation/widgets/event_widgets.dart';
import '../../domain/entities/zone_entities.dart';
import '../bloc/zone_cubits.dart';

/// [FE-14] Màn hình chào mừng du khách quét mã QR tại Sân bay Quốc tế Đà Nẵng.
class AirportArrivalPromoScreen extends StatelessWidget {
  const AirportArrivalPromoScreen({super.key, this.campaignId});

  final String? campaignId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AirportWelcomeCubit>()..load(campaignId: campaignId),
      child: TopographicScaffold(
        seed: 83,
        body: BlocBuilder<AirportWelcomeCubit, AirportWelcomeState>(
          builder: (context, state) {
            if (state.status.isLoading) return const LoadingIndicator(message: 'Xin chào! Đang chuẩn bị gợi ý...');
            if (state.status.isFailure || state.content == null) {
              return ErrorViewWidget(
                message: state.errorMessage ?? 'Không tải được nội dung.',
                onRetry: () => context.read<AirportWelcomeCubit>().load(campaignId: campaignId),
              );
            }
            final c = state.content!;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _WelcomeHero(content: c)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  sliver: SliverList.list(
                    children: [
                      Text(c.message, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          for (final f in c.quickFacts)
                            Expanded(
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.1),
                                    child: Icon(f.icon, color: AppColors.primaryTeal),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(f.value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  Text(f.label,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flight_land_rounded, color: AppColors.primaryTeal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Từ sân bay đến Ngũ Hành Sơn\n${c.distanceFromAirport}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4)),
                                ),
                              ],
                            ),
                            const Divider(height: 22),
                            for (final t in c.travelOptions)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(t.icon, size: 20, color: AppColors.primaryPastel),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          Text(t.detail,
                                              style: const TextStyle(
                                                  color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Text('* Giá và tuyến xe mang tính tham khảo.',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        gradient: AppColors.goldGradient,
                        onTap: () => context.go(RouteNames.checkin),
                        child: Row(
                          children: [
                            const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 34),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(c.welcomeOffer,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, height: 1.4)),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                      if (state.destinations.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(
                          title: 'Điểm đến không thể bỏ lỡ',
                          actionLabel: 'Xem thêm',
                          onAction: () => context.push(RouteNames.destinations),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 290,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.destinations.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 14),
                            itemBuilder: (_, i) => DestinationFeatureCard(destination: state.destinations[i], width: 240),
                          ),
                        ),
                      ],
                      if (state.events.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        SectionHeader(
                          title: 'Sự kiện đặc sắc',
                          actionLabel: 'Tất cả',
                          onAction: () => context.push(RouteNames.events),
                        ),
                        const SizedBox(height: 10),
                        for (final e in state.events) ...[EventCard(event: e), const SizedBox(height: 12)],
                      ],
                      const SizedBox(height: 20),
                      CustomButton(
                        label: 'Bắt đầu khám phá',
                        icon: Icons.explore_rounded,
                        onPressed: () => context.go(RouteNames.explore),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Lên lịch trình bằng AI',
                        icon: Icons.auto_awesome_rounded,
                        gold: true,
                        onPressed: () => context.push(RouteNames.aiPlanner),
                      ),
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

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.content});
  final AirportWelcomeContent content;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 320 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CoverImage(source: content.heroImage, radius: 0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryTeal.withValues(alpha: 0.25),
                        AppColors.textPrimary.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: top + 8,
            left: 12,
            child: CircleIconButton(
              icon: Icons.close_rounded,
              tooltip: 'Đóng',
              onPressed: () => context.canPop() ? context.pop() : context.go(RouteNames.explore),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flight_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Sân bay Quốc tế Đà Nẵng',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(content.headline,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 6),
                const Text('Welcome · 환영합니다 · 欢迎光临',
                    style: TextStyle(color: Colors.white70, fontSize: 13.5, letterSpacing: 0.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
