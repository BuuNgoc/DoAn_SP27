import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../bloc/loyalty_cubit.dart';

/// [FE-08] Quét mã QR tại điểm đến để check-in và nhận điểm.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle(String payload) async {
    if (_handling) return;
    setState(() => _handling = true);
    final cubit = context.read<LoyaltyCubit>();
    final outcome = await cubit.checkIn(payload.trim());
    if (!mounted) return;
    if (outcome.result != null) {
      context.pushReplacement(RouteNames.checkinConfirmation, extra: outcome.result);
    } else {
      showAppSnackBar(context, outcome.error ?? context.tr('loyalty.checkin_failed'), type: SnackType.error);
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _handling = false);
    }
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(context.tr('loyalty.manual_code_title')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: context.tr('loyalty.manual_code_hint')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr('common.cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(context.tr('common.confirm'))),
        ],
      ),
    );
    controller.dispose();
    if (code != null && code.trim().isNotEmpty) await _handle(code);
  }

  Future<void> _demoScan() async {
    final points = context.read<LoyaltyCubit>().state.points;
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceWhite,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('loyalty.demo_scan_title'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('loyalty.demo_scan_subtitle'),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 8),
                for (final p in points)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryTeal),
                    title: Text(p.name),
                    subtitle: Text(p.area),
                    trailing: Text('+${p.points}',
                        style: const TextStyle(color: AppColors.accentSoftGold, fontWeight: FontWeight.w800)),
                    onTap: () => Navigator.pop(ctx, p.qrPayload),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null) await _handle(picked);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((LoyaltyCubit c) => c.state.busy) || _handling;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final value = capture.barcodes.firstOrNull?.rawValue;
                if (value != null) _handle(value);
              },
              errorBuilder: (context, error) => Container(
                color: AppColors.textPrimary,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_rounded, color: Colors.white70, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('loyalty.camera_permission_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ScannerOverlayPainter()))),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                CircleIconButton(
                  icon: Icons.close_rounded,
                  tooltip: context.tr('common.close'),
                  color: Colors.white,
                  background: Colors.black.withValues(alpha: 0.4),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                CircleIconButton(
                  icon: Icons.flash_on_rounded,
                  tooltip: context.tr('loyalty.toggle_flash'),
                  color: Colors.white,
                  background: Colors.black.withValues(alpha: 0.4),
                  onPressed: () => _controller.toggleTorch(),
                ),
                const SizedBox(width: 8),
                CircleIconButton(
                  icon: Icons.cameraswitch_rounded,
                  tooltip: context.tr('loyalty.switch_camera'),
                  color: Colors.white,
                  background: Colors.black.withValues(alpha: 0.4),
                  onPressed: () => _controller.switchCamera(),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.55),
            child: Text(
              busy ? context.tr('loyalty.verifying_qr') : context.tr('loyalty.align_qr_instruction'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          if (busy) const Center(child: CircularProgressIndicator(color: AppColors.primaryPastel)),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: busy ? null : _manualEntry,
                    icon: const Icon(Icons.keyboard_rounded),
                    label: Text(context.tr('loyalty.enter_code_btn')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    onPressed: busy ? null : _demoScan,
                    icon: const Icon(Icons.science_rounded),
                    label: Text(context.tr('loyalty.simulate_scan_btn')),
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

class _ScannerOverlayPainter extends CustomPainter {
  const _ScannerOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width * 0.68;
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side, height: side);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rrect)),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.primaryPastel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
