import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';

/// Tab 3 – "AI & Lịch trình": cổng vào nhận diện ảnh (FE-05), lịch trình RAG
/// và trò chuyện với trợ lý du lịch.
class AiAssistantHubScreen extends StatelessWidget {
  const AiAssistantHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quickQuestions = [
      (context.tr('ai.quick_q1'), Icons.schedule_rounded),
      (context.tr('ai.quick_q2'), Icons.ramen_dining_rounded),
      (context.tr('ai.quick_q3'), Icons.health_and_safety_rounded),
    ];

    return TopographicScaffold(
      seed: 11,
      appBar: CustomAppBar(
        title: context.tr('ai.hub_title'),
        subtitle: context.tr('ai.hub_subtitle'),
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, AppDimensions.bottomNavClearance),
        children: [
          AppCard(
            gradient: AppColors.primaryGradient,
            padding: const EdgeInsets.all(20),
            onTap: () => context.push(RouteNames.aiPlanner),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PillBadge(
                        label: 'RAG · AI',
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.accentSoftGold,
                        background: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('ai.planner_banner_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('ai.planner_banner_subtitle'),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryTeal,
                          minimumSize: const Size(0, 44),
                        ),
                        onPressed: () => context.push(RouteNames.aiPlanner),
                        icon: const Icon(Icons.route_rounded),
                        label: Text(context.tr('ai.create_itinerary_btn')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.map_rounded, size: 84, color: Colors.white.withValues(alpha: 0.25)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ToolCard(
                  icon: Icons.document_scanner_rounded,
                  color: AppColors.primaryTeal,
                  title: context.tr('ai.scan_tool_title'),
                  subtitle: context.tr('ai.scan_tool_subtitle'),
                  onTap: () => context.push(RouteNames.aiScan),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  icon: Icons.forum_rounded,
                  color: AppColors.accentSoftGold,
                  title: context.tr('ai.chat_tool_title'),
                  subtitle: context.tr('ai.chat_tool_subtitle'),
                  onTap: () => context.push(RouteNames.aiChat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: context.tr('ai.quick_suggestions_title'),
            subtitle: context.tr('ai.quick_suggestions_subtitle'),
          ),
          const SizedBox(height: 10),
          for (final q in quickQuestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () => context.push(RouteNames.aiChat, extra: q.$1),
                child: Row(
                  children: [
                    Icon(q.$2, color: AppColors.primaryPastel),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q.$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                    const Icon(Icons.north_east_rounded, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.backgroundSecondary,
            showShadow: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr('ai.hub_disclaimer'),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
        ],
      ),
    );
  }
}
