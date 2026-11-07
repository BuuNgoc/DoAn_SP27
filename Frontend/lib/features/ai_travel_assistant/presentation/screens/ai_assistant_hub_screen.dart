import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
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
    return TopographicScaffold(
      seed: 11,
      appBar: const CustomAppBar(
        title: 'Trợ lý AI SmartTravel',
        subtitle: 'Nhận diện địa danh · Lịch trình thông minh',
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
                      const Text(
                        'Lên lịch trình Ngũ Hành Sơn chỉ trong 30 giây',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cho AI biết thời gian rảnh, ngân sách và sở thích – nhận ngay lộ trình theo giờ.',
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
                        label: const Text('Tạo lịch trình'),
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
                  title: 'Nhận diện địa danh',
                  subtitle: 'Chụp ảnh để AI cho biết bạn đang ở đâu',
                  onTap: () => context.push(RouteNames.aiScan),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToolCard(
                  icon: Icons.forum_rounded,
                  color: AppColors.accentSoftGold,
                  title: 'Hỏi đáp du lịch',
                  subtitle: 'Giá vé, giờ mở cửa, ẩm thực, an toàn',
                  onTap: () => context.push(RouteNames.aiChat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Gợi ý nhanh', subtitle: 'Chạm để hỏi trợ lý AI'),
          const SizedBox(height: 10),
          for (final q in const [
            ('Nên tham quan Ngũ Hành Sơn vào giờ nào?', Icons.schedule_rounded),
            ('Gợi ý món ăn ngon gần làng đá Non Nước', Icons.ramen_dining_rounded),
            ('Lưu ý an toàn khi tắm biển Sơn Thủy', Icons.health_and_safety_rounded),
          ])
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kết quả do AI tạo ra chỉ mang tính tham khảo. Vui lòng kiểm tra lại giờ mở cửa, '
                    'giá vé và thông tin an toàn tại điểm đến trước khi tham quan.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
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
