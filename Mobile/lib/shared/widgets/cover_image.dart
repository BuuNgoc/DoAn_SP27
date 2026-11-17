import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Ảnh bìa dùng chung: nhận đường dẫn asset (`assets/...`) hoặc URL mạng.
///
/// URL mạng luôn đi qua [CachedNetworkImage] để xem lại được khi ngoại tuyến;
/// nếu lỗi sẽ hiện nền gradient pastel kèm biểu tượng thay vì ô trống.
class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.landscape_rounded,
  });

  final String source;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (source.isEmpty) {
      image = _fallback();
    } else if (source.startsWith('http')) {
      image = CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => _fallback(loading: true),
        errorWidget: (_, _, _) => _fallback(),
      );
    } else {
      image = Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (radius == 0) return image;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }

  Widget _fallback({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundSecondary, AppColors.contourLineColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(fallbackIcon, color: AppColors.primaryPastel, size: 36),
      ),
    );
  }
}
