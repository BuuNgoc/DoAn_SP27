import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/vr360_audio_cubits.dart';
import '../widgets/audio_guide_player_sheet.dart';

/// [FE-03] Màn hình thuyết minh tự động toàn trang.
class AudioGuideScreen extends StatelessWidget {
  const AudioGuideScreen({super.key, required this.destinationId});

  final String destinationId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AudioGuideCubit>()..load(destinationId),
      child: TopographicScaffold(
        appBar: const CustomAppBar(title: 'Thuyết minh tự động', subtitle: 'Audio Guide đa ngôn ngữ'),
        body: BlocBuilder<AudioGuideCubit, AudioGuideState>(
          builder: (context, state) {
            if (state.status.isFailure) {
              return ErrorViewWidget(
                message: state.errorMessage ?? 'Không tải được thuyết minh.',
                onRetry: () => context.read<AudioGuideCubit>().load(destinationId),
              );
            }
            if (state.guide == null) return const LoadingIndicator();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                AppCard(child: AudioGuidePlayerPanel(state: state)),
                const SizedBox(height: 18),
                AudioTranscriptCard(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}
