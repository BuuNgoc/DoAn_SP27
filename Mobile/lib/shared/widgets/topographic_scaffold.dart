import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Vẽ các đường đồng mức địa hình (topographic contour) uốn lượn bằng đường
/// cong Bezier – gợi vân đá cẩm thạch của núi Ngũ Hành Sơn.
///
/// Các "đỉnh núi" được đặt cố định theo [seed] để hoa văn ổn định giữa các
/// lần build (không nhấp nháy khi rebuild).
class TopographicContourPainter extends CustomPainter {
  TopographicContourPainter({
    this.lineColor = AppColors.contourLineColor,
    this.strokeWidth = 1.2,
    this.seed = 7,
  });

  final Color lineColor;
  final double strokeWidth;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final random = math.Random(seed);

    // Ba cụm "đỉnh núi" – mỗi cụm là tập các vòng đồng mức lồng nhau.
    final peaks = <Offset>[
      Offset(size.width * 0.12, size.height * 0.10),
      Offset(size.width * 0.92, size.height * 0.42),
      Offset(size.width * 0.30, size.height * 0.88),
    ];

    for (final peak in peaks) {
      final rings = 9 + random.nextInt(4);
      final phase = random.nextDouble() * math.pi * 2;
      for (var r = 1; r <= rings; r++) {
        final baseRadius = r * (size.shortestSide * 0.055);
        canvas.drawPath(_contourRing(peak, baseRadius, phase + r * 0.18, random), paint);
      }
    }

    // Các đường vân dài chạy ngang màn hình giữa những cụm núi.
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.22 + i * 0.11);
      final path = Path()..moveTo(-20, y);
      final segments = 4;
      for (var s = 0; s < segments; s++) {
        final x0 = size.width * s / segments;
        final x1 = size.width * (s + 1) / segments;
        final amp = 18 + random.nextDouble() * 22;
        final dir = s.isEven ? 1 : -1;
        path.cubicTo(
          x0 + (x1 - x0) * 0.35, y + amp * dir,
          x0 + (x1 - x0) * 0.65, y - amp * dir,
          x1 + (s == segments - 1 ? 20 : 0), y + (random.nextDouble() - 0.5) * 10,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  /// Một vòng đồng mức khép kín, bán kính dao động nhẹ để trông tự nhiên.
  Path _contourRing(Offset center, double radius, double phase, math.Random random) {
    const points = 8;
    final pts = <Offset>[];
    for (var i = 0; i < points; i++) {
      final angle = (i / points) * math.pi * 2;
      final wobble = 1 + 0.16 * math.sin(angle * 3 + phase) + 0.06 * math.cos(angle * 5 + phase);
      pts.add(Offset(
        center.dx + math.cos(angle) * radius * wobble * 1.25,
        center.dy + math.sin(angle) * radius * wobble,
      ));
    }

    final path = Path();
    final first = Offset((pts.last.dx + pts.first.dx) / 2, (pts.last.dy + pts.first.dy) / 2);
    path.moveTo(first.dx, first.dy);
    for (var i = 0; i < points; i++) {
      final current = pts[i];
      final next = pts[(i + 1) % points];
      final mid = Offset((current.dx + next.dx) / 2, (current.dy + next.dy) / 2);
      path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant TopographicContourPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.seed != seed;
}

/// Lớp nền vân địa hình đứng riêng – dùng được bên trong Stack bất kỳ.
class TopographicBackground extends StatelessWidget {
  const TopographicBackground({super.key, this.seed = 7});

  final int seed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: TopographicContourPainter(seed: seed),
        size: Size.infinite,
      ),
    );
  }
}

/// Scaffold chuẩn của SmartTravel: nền Ice-Mint `#F4FAFA` + vân địa hình
/// `#E0EFEF` phía sau toàn bộ nội dung.
class TopographicScaffold extends StatelessWidget {
  const TopographicScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.seed = 7,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final int seed;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundIceMint,
      extendBody: extendBody,
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          Positioned.fill(child: TopographicBackground(seed: seed)),
          Positioned.fill(child: body),
        ],
      ),
    );
  }
}
