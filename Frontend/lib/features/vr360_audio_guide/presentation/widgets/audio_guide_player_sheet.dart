import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../domain/entities/vr360_audio_entities.dart';
import '../bloc/vr360_audio_cubits.dart';

String formatAudioTime(double seconds) {
  final s = seconds.round();
  final m = s ~/ 60;
  final r = s % 60;
  return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
}

/// [FE-03] Bottom sheet trình phát thuyết minh – dùng ở trang chi tiết và VR360.
class AudioGuidePlayerSheet extends StatelessWidget {
  const AudioGuidePlayerSheet({super.key});

  static Future<void> show(BuildContext context, {required String destinationId}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<AudioGuideCubit>()..load(destinationId),
        child: const AudioGuidePlayerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: BlocBuilder<AudioGuideCubit, AudioGuideState>(
            builder: (context, state) {
              if (state.status.isLoading || state.status == ViewStatus.initial) {
                return SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: LoadingIndicator(message: context.tr('audio_guide.loading')),
                );
              }
              if (state.status.isFailure || state.guide == null) {
                return SingleChildScrollView(
                  controller: controller,
                  child: ErrorViewWidget(message: state.errorMessage ?? context.tr('audio_guide.load_error')),
                );
              }
              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AudioGuidePlayerPanel(state: state),
                  const SizedBox(height: 20),
                  AudioTranscriptCard(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Khối điều khiển: tiêu đề, chọn ngôn ngữ, thanh tua, Play/Pause.
class AudioGuidePlayerPanel extends StatelessWidget {
  const AudioGuidePlayerPanel({super.key, required this.state});

  final AudioGuideState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AudioGuideCubit>();
    final guide = state.guide!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.headphones_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guide.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(
                    '${guide.narrator} · ${formatAudioTime(guide.durationSeconds.toDouble())}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          context.tr('audio_guide.language_label'),
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lang in AudioLanguage.values)
              ChoiceChip(
                label: Text('${lang.flag} ${lang.label}'),
                selected: state.language == lang,
                onSelected: (_) => cubit.changeLanguage(lang),
              ),
          ],
        ),
        if (state.isFallbackLanguage) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate_rounded, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('audio_guide.fallback_notice', params: {'lang': state.language.label}),
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(trackHeight: 5),
          child: Slider(
            value: state.positionSeconds.clamp(0, state.durationSeconds.toDouble()),
            max: state.durationSeconds.toDouble() == 0 ? 1 : state.durationSeconds.toDouble(),
            onChanged: cubit.seek,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatAudioTime(state.positionSeconds), style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(formatAudioTime(state.durationSeconds.toDouble()),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: cubit.cycleSpeed,
              child: Text('${state.speed}x', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              iconSize: 32,
              tooltip: context.tr('audio_guide.rewind_15s'),
              onPressed: () => cubit.skip(-15),
              icon: const Icon(Icons.replay_10_rounded, color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: cubit.togglePlay,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryTeal.withValues(alpha: state.isPlaying ? 0.35 : 0.18),
                      blurRadius: state.isPlaying ? 22 : 12,
                    ),
                  ],
                ),
                child: Icon(
                  state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                  semanticLabel: state.isPlaying ? context.tr('audio_guide.pause') : context.tr('audio_guide.play'),
                ),
              ),
            ),
            IconButton(
              iconSize: 32,
              tooltip: context.tr('audio_guide.forward_15s'),
              onPressed: () => cubit.skip(15),
              icon: const Icon(Icons.forward_10_rounded, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            state.isPlaying
                ? context.tr('audio_guide.status_playing')
                : (state.positionSeconds > 0 && !state.isFinished
                    ? context.tr('audio_guide.status_paused')
                    : context.tr('audio_guide.status_idle')),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Khung đọc nội dung thuyết minh (transcript).
class AudioTranscriptCard extends StatelessWidget {
  const AudioTranscriptCard({super.key, required this.state});

  final AudioGuideState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(context.tr('audio_guide.transcript_title'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            state.guide!.transcriptFor(state.language),
            style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14.5),
          ),
        ],
      ),
    );
  }
}
