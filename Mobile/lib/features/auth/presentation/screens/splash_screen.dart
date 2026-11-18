import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';

/// [Ảnh Mẫu 1] Splash Screen: Nghệ thuật Thủy Mặc & Đường Đồng Mức Địa Hình Ngũ Hành Sơn.
/// - Nền giấy ngà Warm Ivory (#FAF7F2).
/// - Đường đồng mức uốn lượn màu vàng kim (#B69A67).
/// - Logo ấn ngọc hoàng gia tròn chính giữa với họa tiết đỉnh núi cách điệu.
/// - Các dải núi thủy mặc xanh rêu (Sage Green & Deep Forest) lớp lớp phía dưới.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Tự động chuyển tiếp vào trang chủ sau khi animation hoàn tất
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(RouteNames.explore);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0), // Warm Parchment/Ivory
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Đường đồng mức địa hình uốn lượn ở đỉnh màn hình ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: CustomPaint(
              painter: _TopWaveContourPainter(),
            ),
          ),

          // ── 2. Dãy núi thủy mặc xanh rêu đa tầng dưới chân núi ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 380,
            child: CustomPaint(
              painter: _WatercolorMountainPainter(),
            ),
          ),

          // ── 3. Logo Ấn Ngọc Hoàng Gia & Tên Danh Thắng ở trung tâm ──────────
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Biểu tượng ấn ngọc vàng kim (Gold Emblem Circle)
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37), // Luxury Imperial Gold
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomPaint(
                              size: const Size(44, 30),
                              painter: _MountainPeakLogoPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Tên thương hiệu phong cách Shangri-La
                        const Text(
                          'SMART TRAVEL',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 6.0,
                            color: Color(0xFF173F35), // Deep Forest Green
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'NGŨ HÀNH SƠN • ĐÀ NẴNG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.5,
                            color: Color(0xFFB69A67), // Soft Gold
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ các nếp sóng đồng mức mảnh mai ở phần trên màn hình (theo đúng ảnh mẫu 1)
class _TopWaveContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B886).withValues(alpha: 0.55) // Gold Ochre
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    for (int i = 0; i < 9; i++) {
      final path = Path();
      final baseY = 40.0 + i * 14.0;
      path.moveTo(-20, baseY);

      path.cubicTo(
        size.width * 0.25, baseY + 28 * math.sin(i * 0.4),
        size.width * 0.65, baseY - 32 * math.cos(i * 0.35),
        size.width + 20, baseY + 12,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vẽ dãy núi thủy mặc Ngũ Hành Sơn 3 tầng với hoa văn vân đá cẩm thạch (theo ảnh mẫu 1)
class _WatercolorMountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tầng 1: Núi xa mờ nhạt (Light Moss Green)
    final paintLayer1 = Paint()
      ..color = const Color(0xFFB8C5B4).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.20, size.width * 0.55, size.height * 0.48)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.15, size.width, size.height * 0.35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paintLayer1);

    // Hoa văn nứt vân đá cẩm thạch trên tầng núi xa
    final cracklePaint = Paint()
      ..color = const Color(0xFF8A9A86).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double x = 40; x < size.width; x += 32) {
      final p = Path()..moveTo(x, size.height * 0.40);
      p.lineTo(x + 12, size.height * 0.48);
      p.lineTo(x - 6, size.height * 0.58);
      canvas.drawPath(p, cracklePaint);
    }

    // Tầng 2: Núi gần xanh ngọc mướt (Sage Green)
    final paintLayer2 = Paint()
      ..color = const Color(0xFF8DA089).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(-20, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.62, size.width * 0.30, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.40, size.width + 20, size.height * 0.85)
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-20, size.height)
      ..close();
    canvas.drawPath(path2, paintLayer2);

    // Tầng 3: Ngọn núi cận cảnh hùng vĩ (Deep Olive Moss)
    final paintLayer3 = Paint()
      ..color = const Color(0xFF6B7E67).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    final path3 = Path()
      ..moveTo(size.width * 0.20, size.height)
      ..quadraticBezierTo(size.width * 0.60, size.height * 0.60, size.width + 20, size.height * 0.95)
      ..lineTo(size.width + 20, size.height)
      ..close();
    canvas.drawPath(path3, paintLayer3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vẽ biểu tượng đỉnh núi kép cách điệu trong ấn ngọc hoàng gia (ảnh mẫu 1 & 2)
class _MountainPeakLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37) // Gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Vòm núi trên
    final topPeak = Path()
      ..moveTo(size.width * 0.15, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 0.85, size.height * 0.45);
    canvas.drawPath(topPeak, paint);

    // Vòm lũng dưới đối xứng
    final bottomValley = Path()
      ..moveTo(size.width * 0.18, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.92, size.width * 0.82, size.height * 0.55);
    canvas.drawPath(bottomValley, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

