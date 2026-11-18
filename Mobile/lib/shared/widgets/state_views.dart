import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'tourism_buttons.dart';

/// Trạng thái tải dữ liệu (Loading State) đồng bộ toàn ứng dụng.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Đang tải dữ liệu...',
    this.height,
  });

  final String message;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              boxShadow: AppColors.softShadow,
            ),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: content);
    }
    return content;
  }
}

/// Trạng thái trống (Empty State) với đồ họa tối giản và nút hành động.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.travel_explore_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.backgroundSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction!,
                height: 44,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Trạng thái lỗi (Error State) kèm nút Thử lại - Khắc phục hoàn toàn lỗi UI Overflow.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Thử lại',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon đám mây gạch chéo trong khung tròn hồng nhạt theo đúng ảnh mẫu
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFDF0EF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF7D1CE), width: 1.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 36,
                  color: Color(0xFFB83A2E), // Muted Terracotta Red
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đã xảy ra sự cố',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF242824),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.isNotEmpty ? message : 'An unexpected error occurred. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Color(0xFF70736C),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF173F35),
                  side: const BorderSide(color: Color(0xFFE2DDD5), width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF173F35)),
                label: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF173F35),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget tạo hiệu ứng lấp lánh (Shimmer Animation) mượt mà không cần thư viện ngoài.
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEDE9E1),
    this.highlightColor = const Color(0xFFFAF7F2),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer Loading dạng thẻ điểm đến chuẩn bị hiển thị danh sách Ngũ Hành Sơn.
class DestinationListShimmer extends StatelessWidget {
  const DestinationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ShimmerEffect(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, _) => Container(
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEBE7DE), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9E1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 140, color: const Color(0xFFEDE9E1)),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 180, color: const Color(0xFFEDE9E1)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 12, width: 40, color: const Color(0xFFEDE9E1)),
                          Container(
                            height: 18,
                            width: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDE9E1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

