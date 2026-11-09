import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/map_poi.dart';

/// Phép chiếu tuyến tính vĩ độ/kinh độ → tọa độ canvas cho khu vực Ngũ Hành Sơn.
class MapProjection {
  const MapProjection();

  static const double minLat = 15.994;
  static const double maxLat = 16.054;
  static const double minLng = 108.240;
  static const double maxLng = 108.276;
  static const Size canvasSize = Size(900, 1560);

  Offset toCanvas(double lat, double lng) => Offset(
        (lng - minLng) / (maxLng - minLng) * canvasSize.width,
        (maxLat - lat) / (maxLat - minLat) * canvasSize.height,
      );
}

/// Bản đồ phong cách hóa quận Ngũ Hành Sơn: biển, bờ cát, trục đường chính,
/// cụm 5 ngọn núi với đường đồng mức và khu phố An Thượng.
///
/// Dùng thay Google Maps trong bản demo (không cần API key). Khi có key, có thể
/// thay bằng `GoogleMap` từ gói `google_maps_flutter` với cùng danh sách POI.
class NguHanhSonMapPainter extends CustomPainter {
  const NguHanhSonMapPainter();

  static const _p = MapProjection();

  static const _coast = [
    (16.054, 108.2515),
    (16.045, 108.2525),
    (16.035, 108.2555),
    (16.025, 108.2585),
    (16.015, 108.2630),
    (16.005, 108.2690),
    (15.994, 108.2745),
  ];

  Path _coastPath({double lngOffset = 0}) {
    final path = Path();
    for (var i = 0; i < _coast.length; i++) {
      final o = _p.toCanvas(_coast[i].$1, _coast[i].$2 + lngOffset);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        final prev = _p.toCanvas(_coast[i - 1].$1, _coast[i - 1].$2 + lngOffset);
        final mid = Offset((prev.dx + o.dx) / 2, (prev.dy + o.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
        if (i == _coast.length - 1) path.lineTo(o.dx, o.dy);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Đất liền
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7FBF8));

    // Mảng xanh công viên/đồng
    final green = Paint()..color = const Color(0xFFE6F3EA);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.18, h * 0.62), width: 260, height: 180), green);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.3, h * 0.25), width: 200, height: 150), green);

    // Biển
    final sea = _coastPath()
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(
      sea,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD5ECF5), Color(0xFFBFE2F0)],
        ).createShader(Offset.zero & size),
    );
    // Sóng
    final wave = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < 14; i++) {
      final y = 60.0 + i * 110;
      final x = w * 0.78 + (i.isEven ? 0 : 40);
      final path = Path()..moveTo(x, y);
      path.relativeQuadraticBezierTo(15, -8, 30, 0);
      path.relativeQuadraticBezierTo(15, 8, 30, 0);
      canvas.drawPath(path, wave);
    }

    // Bờ cát
    canvas.drawPath(
      _coastPath(lngOffset: -0.0004),
      Paint()
        ..color = const Color(0xFFF3E6C4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );

    // Đường giao thông
    final roadCasing = Paint()
      ..color = const Color(0xFFDDE7E7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final coastal = _coastPath(lngOffset: -0.0016);
    final leVanHien = Path()
      ..moveTo(_p.toCanvas(16.054, 108.2425).dx, _p.toCanvas(16.054, 108.2425).dy)
      ..quadraticBezierTo(
        _p.toCanvas(16.025, 108.2500).dx,
        _p.toCanvas(16.025, 108.2500).dy,
        _p.toCanvas(15.994, 108.2600).dx,
        _p.toCanvas(15.994, 108.2600).dy,
      );
    final huyenTran = Path()
      ..moveTo(_p.toCanvas(16.0028, 108.2585).dx, _p.toCanvas(16.0028, 108.2585).dy)
      ..lineTo(_p.toCanvas(16.0022, 108.2705).dx, _p.toCanvas(16.0022, 108.2705).dy);
    final anThuongRoad = Path()
      ..moveTo(_p.toCanvas(16.0478, 108.2435).dx, _p.toCanvas(16.0478, 108.2435).dy)
      ..lineTo(_p.toCanvas(16.0478, 108.2505).dx, _p.toCanvas(16.0478, 108.2505).dy);

    for (final r in [coastal, leVanHien, huyenTran, anThuongRoad]) {
      canvas.drawPath(r, roadCasing);
      canvas.drawPath(r, road);
    }

    // Khu An Thượng
    final at = Rect.fromPoints(_p.toCanvas(16.0498, 108.2430), _p.toCanvas(16.0458, 108.2495));
    canvas.drawRRect(
      RRect.fromRectAndRadius(at, const Radius.circular(24)),
      Paint()..color = MapLayer.anThuong.color.withValues(alpha: 0.10),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(at, const Radius.circular(24)),
      Paint()
        ..color = MapLayer.anThuong.color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Làng đá Non Nước
    final village = _p.toCanvas(16.0002, 108.2636);
    canvas.drawOval(
      Rect.fromCenter(center: village, width: 170, height: 70),
      Paint()..color = AppColors.accentSoftGold.withValues(alpha: 0.12),
    );

    // Cụm Ngũ Hành Sơn với đường đồng mức
    const mountains = [
      ('Thủy Sơn', 16.0042, 108.2636, 80.0),
      ('Mộc Sơn', 16.0070, 108.2612, 38.0),
      ('Kim Sơn', 15.9975, 108.2585, 34.0),
      ('Hỏa Sơn', 16.0015, 108.2600, 40.0),
      ('Thổ Sơn', 16.0068, 108.2660, 42.0),
    ];
    for (final m in mountains) {
      final c = _p.toCanvas(m.$2, m.$3);
      _drawMountain(canvas, c, m.$4);
    }

    // Nhãn
    _label(canvas, AppLocalizations.trStatic('map.canvas_east_sea'), Offset(w * 0.86, h * 0.45), size: 20, color: const Color(0xFF7FB5CA), spacing: 4, rotate: -1.2);
    _label(canvas, AppLocalizations.trStatic('map.canvas_ngu_hanh_son'), _p.toCanvas(16.0090, 108.2636), size: 15, color: AppColors.primaryTeal, spacing: 2);
    _label(canvas, AppLocalizations.trStatic('map.canvas_non_nuoc_village'), village + const Offset(0, 46), size: 12, color: const Color(0xFFB98A3A));
    _label(canvas, AppLocalizations.trStatic('map.canvas_an_thuong_zone'), Offset(at.center.dx, at.top - 14), size: 12, color: MapLayer.anThuong.color);
    _label(canvas, 'Đường Lê Văn Hiến', _p.toCanvas(16.030, 108.2483), size: 11, color: AppColors.textMuted, rotate: -1.33);
    _label(canvas, 'Đường Võ Nguyên Giáp', _p.toCanvas(16.038, 108.2527), size: 11, color: AppColors.textMuted, rotate: -1.38);
    _label(canvas, 'Huyền Trân Công Chúa', _p.toCanvas(16.0018, 108.2672), size: 10, color: AppColors.textMuted);
  }

  void _drawMountain(Canvas canvas, Offset c, double r) {
    final rand = math.Random(c.dx.toInt());
    for (var ring = 4; ring >= 1; ring--) {
      final rr = r * ring / 4 + 10;
      final path = Path();
      const steps = 28;
      final offsets = List.generate(steps, (_) => 0.82 + rand.nextDouble() * 0.28);
      for (var i = 0; i <= steps; i++) {
        final a = i / steps * math.pi * 2;
        final k = offsets[i % steps];
        final p = c + Offset(math.cos(a) * rr * k, math.sin(a) * rr * k * 0.82);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      final t = (5 - ring) / 4;
      canvas.drawPath(
        path,
        Paint()..color = Color.lerp(const Color(0xFFDCEEE6), const Color(0xFF9CCFC0), t)!,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF7DB8A8).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset center, {
    double size = 12,
    Color color = AppColors.textSecondary,
    double spacing = 0.5,
    double rotate = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w700, letterSpacing: spacing),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotate != 0) canvas.rotate(rotate);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NguHanhSonMapPainter oldDelegate) => false;
}

/// Ghim POI trên bản đồ.
class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.poi, required this.selected, required this.onTap});

  final MapPoi poi;
  final bool selected;
  final VoidCallback onTap;

  static const double width = 44;
  static const double height = 54;

  @override
  Widget build(BuildContext context) {
    final color = poi.layer.color;
    return Tooltip(
      message: poi.name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.25 : 1,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: selected ? 14 : 6)],
                  ),
                  child: Icon(poi.layer.icon, color: Colors.white, size: 18),
                ),
                CustomPaint(size: const Size(12, 10), painter: _PinTailPainter(color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.color != color;
}
