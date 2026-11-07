import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../domain/entities/ai_entities.dart';
import '../bloc/ai_cubits.dart';

/// Tham số chuyển sang màn hình kết quả nhận diện.
class RecognitionResultArgs {
  const RecognitionResultArgs({required this.result, required this.imageBytes});
  final LandmarkRecognition result;
  final Uint8List imageBytes;
}

/// [FE-05] Chụp hoặc tải ảnh lên để AI nhận diện địa danh.
class AiPhotoScanScreen extends StatelessWidget {
  const AiPhotoScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AiScanCubit>(),
      child: BlocConsumer<AiScanCubit, AiScanState>(
        listener: (context, state) {
          if (state.status.isSuccess && state.result != null) {
            context.push(
              RouteNames.aiResult,
              extra: RecognitionResultArgs(result: state.result!, imageBytes: state.imageBytes!),
            );
          } else if (state.status.isFailure) {
            showAppSnackBar(context, state.errorMessage ?? 'Không nhận diện được ảnh.', type: SnackType.error);
          }
        },
        builder: (context, state) {
          final cubit = context.read<AiScanCubit>();
          return TopographicScaffold(
            appBar: const CustomAppBar(title: 'Nhận diện địa danh', subtitle: 'AI Photo Recognition'),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: _ScanFrame(bytes: state.imageBytes, scanning: state.status.isLoading),
                ),
                const SizedBox(height: 20),
                if (state.imageBytes == null) ...[
                  const Text(
                    'Hướng camera về phía công trình, hang động hoặc cảnh quan bạn muốn tìm hiểu. '
                    'AI sẽ cho biết tên địa danh kèm độ tin cậy và thông tin liên quan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Chụp ảnh',
                        icon: Icons.photo_camera_rounded,
                        onPressed: state.status.isLoading ? null : () => _pick(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                        onPressed: state.status.isLoading ? null : () => _pick(context, ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('Tải ảnh lên'),
                      ),
                    ),
                  ],
                ),
                if (state.imageBytes != null) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    label: state.status.isLoading ? 'AI đang phân tích...' : 'Nhận diện ngay',
                    icon: Icons.auto_awesome_rounded,
                    gold: true,
                    isLoading: state.status.isLoading,
                    onPressed: cubit.analyze,
                  ),
                ],
                const SizedBox(height: 20),
                const _TipsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final cubit = context.read<AiScanCubit>();
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (file == null) return;
      cubit.setImage(await file.readAsBytes());
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          source == ImageSource.camera
              ? 'Không mở được camera. Vui lòng cấp quyền hoặc chọn ảnh từ thư viện.'
              : 'Không mở được thư viện ảnh.',
          type: SnackType.warning,
        );
      }
    }
  }
}

class _ScanFrame extends StatefulWidget {
  const _ScanFrame({required this.bytes, required this.scanning});

  final Uint8List? bytes;
  final bool scanning;

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.bytes != null)
            Image.memory(widget.bytes!, fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 56, color: AppColors.primaryPastel),
                  SizedBox(height: 12),
                  Text('Chưa có ảnh', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ),
            ),
          // Khung ngắm 4 góc
          const Padding(padding: EdgeInsets.all(22), child: CustomPaint(painter: _CornerPainter())),
          if (widget.scanning) ...[
            Container(color: AppColors.primaryTeal.withValues(alpha: 0.18)),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Align(
                alignment: Alignment(0, -1 + _controller.value * 2),
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoftGold,
                    boxShadow: [
                      BoxShadow(color: AppColors.accentSoftGold.withValues(alpha: 0.8), blurRadius: 18, spreadRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment(0, 0.85),
              child: Chip(
                avatar: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentSoftGold),
                label: Text('Đang so khớp với cơ sở dữ liệu địa danh...'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryPastel
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const l = 34.0;
    final w = size.width, h = size.height;
    for (final c in [
      [Offset(0, l), Offset.zero, const Offset(l, 0)],
      [Offset(w - l, 0), Offset(w, 0), Offset(w, l)],
      [Offset(0, h - l), Offset(0, h), Offset(l, h)],
      [Offset(w - l, h), Offset(w, h), Offset(w, h - l)],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c[0].dx, c[0].dy)
          ..lineTo(c[1].dx, c[1].dy)
          ..lineTo(c[2].dx, c[2].dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mẹo để AI nhận diện chính xác hơn', style: TextStyle(fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('• Chụp ở nơi đủ sáng, giữ máy ổn định.', style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
          Text('• Lấy trọn chủ thể chính (cổng chùa, cửa động, tượng...).',
              style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
          Text('• Tránh để người hoặc vật che khuất quá nhiều.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
