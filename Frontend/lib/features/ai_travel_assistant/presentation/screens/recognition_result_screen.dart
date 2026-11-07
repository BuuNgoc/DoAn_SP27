import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../destination_discovery/domain/entities/destination.dart';
import '../../../destination_discovery/domain/usecases/destination_usecases.dart';
import '../../../destination_discovery/presentation/widgets/destination_widgets.dart';
import '../../domain/entities/ai_entities.dart';
import 'ai_photo_scan_screen.dart';

/// [FE-05] Kết quả nhận diện: tên địa danh, huy hiệu độ tin cậy, ghi chú tham khảo
/// (LI-02), nội dung liên quan và lối sang trang chi tiết điểm đến.
class RecognitionResultScreen extends StatelessWidget {
  const RecognitionResultScreen({super.key, this.args});

  final RecognitionResultArgs? args;

  @override
  Widget build(BuildContext context) {
    final a = args;
    if (a == null) {
      return TopographicScaffold(
        appBar: const CustomAppBar(title: 'Kết quả nhận diện'),
        body: EmptyStateWidget(
          icon: Icons.image_search_rounded,
          title: 'Chưa có kết quả',
          message: 'Hãy chụp hoặc tải ảnh lên để AI nhận diện địa danh.',
          actionLabel: 'Quét ảnh',
          onAction: () => context.pushReplacement(RouteNames.aiScan),
        ),
      );
    }
    final r = a.result;
    return TopographicScaffold(
      appBar: const CustomAppBar(title: 'Kết quả nhận diện'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                AspectRatio(aspectRatio: 4 / 3, child: Image.memory(a.imageBytes, fit: BoxFit.cover)),
                Positioned(top: 12, right: 12, child: ConfidenceBadge(confidence: r.confidence)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(r.landmarkName, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          _ConfidenceMeter(result: r),
          const SizedBox(height: 14),
          _ReferenceNotice(lowConfidence: r.isLowConfidence),
          const SizedBox(height: 18),
          Text(r.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 15)),
          if (r.funFacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.accentSoftGold.withValues(alpha: 0.08),
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: AppColors.accentSoftGold),
                      SizedBox(width: 8),
                      Text('Có thể bạn chưa biết', style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final f in r.funFacts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $f', style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                    ),
                ],
              ),
            ),
          ],
          if (r.alternatives.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Khả năng khác', subtitle: 'Các địa danh có đặc điểm tương tự'),
            const SizedBox(height: 8),
            for (final c in r.alternatives)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.textMuted),
                title: Text(c.name),
                trailing: Text('${(c.confidence * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                onTap: c.destinationId == null ? null : () => context.push(RouteNames.destinationDetail(c.destinationId!)),
              ),
          ],
          if (r.destinationId != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              label: 'Xem chi tiết điểm đến',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.push(RouteNames.destinationDetail(r.destinationId!)),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Quét ảnh khác'),
          ),
          if (r.relatedDestinationIds.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Nội dung liên quan', subtitle: 'Gợi ý điểm đến gần đó'),
            const SizedBox(height: 10),
            _RelatedDestinations(ids: r.relatedDestinationIds),
          ],
        ],
      ),
    );
  }
}

/// Huy hiệu phần trăm độ tin cậy, đổi màu theo mức.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final double confidence;

  static Color colorOf(double c) =>
      c >= 0.8 ? AppColors.success : (c >= kLowConfidenceThreshold ? AppColors.warning : AppColors.error);

  @override
  Widget build(BuildContext context) {
    final color = colorOf(confidence);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            'Độ tin cậy ${(confidence * 100).round()}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({required this.result});

  final LandmarkRecognition result;

  @override
  Widget build(BuildContext context) {
    final color = ConfidenceBadge.colorOf(result.confidence);
    final label = result.confidence >= 0.8
        ? 'Độ tin cậy cao'
        : (result.isLowConfidence ? 'Độ tin cậy thấp' : 'Độ tin cậy trung bình');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${result.confidencePercent}%', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: result.confidence),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 10,
              color: color,
              backgroundColor: AppColors.backgroundSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice({required this.lowConfidence});

  final bool lowConfidence;

  @override
  Widget build(BuildContext context) {
    final color = lowConfidence ? AppColors.warning : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (lowConfidence ? AppColors.warning : AppColors.primaryPastel).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (lowConfidence ? AppColors.warning : AppColors.primaryPastel).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(lowConfidence ? Icons.warning_amber_rounded : Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lowConfidence
                  ? 'AI chưa chắc chắn về địa danh này. Kết quả chỉ mang tính gợi ý – bạn hãy chụp lại rõ hơn '
                      'hoặc đối chiếu với biển chỉ dẫn tại chỗ.'
                  : 'Kết quả nhận diện bằng AI chỉ mang tính tham khảo và có thể chưa chính xác tuyệt đối. '
                      'Vui lòng đối chiếu với biển chỉ dẫn tại điểm đến.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedDestinations extends StatelessWidget {
  const _RelatedDestinations({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Destination>>(
      future: sl<GetDestinationsUseCase>()(),
      builder: (context, snap) {
        if (!snap.hasData) return const Padding(padding: EdgeInsets.all(16), child: LoadingIndicator());
        final items = snap.data!.where((d) => ids.contains(d.id)).toList();
        return Column(
          children: [
            for (final d in items)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: DestinationListTile(destination: d)),
          ],
        );
      },
    );
  }
}
