import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/events_cubits.dart';
import 'stone_carving_contest_screen.dart';

/// [FE-16] Chi tiết tác phẩm dự thi: thông tin, thứ hạng, bình chọn, chia sẻ.
class ContestEntryDetailScreen extends StatelessWidget {
  const ContestEntryDetailScreen({super.key, required this.contestId, required this.entryId});

  final String contestId;
  final String entryId;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.uid;
    return BlocProvider(
      create: (_) => sl<ContestCubit>()..load(userId: userId),
      child: BlocBuilder<ContestCubit, ContestState>(
        builder: (context, state) {
          if (state.status.isFailure && state.contest == null) {
            return TopographicScaffold(
              appBar: const CustomAppBar(title: 'Tác phẩm dự thi'),
              body: ErrorViewWidget(message: state.errorMessage ?? 'Không tải được tác phẩm.'),
            );
          }
          final index = state.entries.indexWhere((e) => e.id == entryId);
          if (state.contest == null || index < 0) {
            return TopographicScaffold(
              appBar: const CustomAppBar(title: 'Tác phẩm dự thi'),
              body: state.status.isSuccess
                  ? const EmptyStateWidget(icon: Icons.search_off_rounded, title: 'Không tìm thấy tác phẩm')
                  : const LoadingIndicator(),
            );
          }
          final e = state.entries[index];
          final voting = state.votingEntryId == e.id;
          return TopographicScaffold(
            appBar: CustomAppBar(
              title: 'Tác phẩm dự thi',
              actions: [
                CircleIconButton(icon: Icons.ios_share_rounded, tooltip: 'Chia sẻ', onPressed: () => shareEntry(context, e)),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                GestureDetector(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.all(12),
                      backgroundColor: Colors.black,
                      child: InteractiveViewer(child: CoverImage(source: e.image, fit: BoxFit.contain, radius: 0)),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(aspectRatio: 4 / 3, child: CoverImage(source: e.image, radius: 0)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Text(e.title, style: Theme.of(context).textTheme.headlineSmall)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: index == 0 ? AppColors.goldGradient : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('Hạng ${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${e.artistName} · ${e.artistOrigin}', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                AppCard(
                  child: Row(
                    children: [
                      _Fact(icon: Icons.texture_rounded, label: 'Chất liệu', value: e.material),
                      _Fact(icon: Icons.straighten_rounded, label: 'Kích thước', value: e.dimensions),
                      _Fact(
                        icon: Icons.favorite_rounded,
                        label: 'Bình chọn',
                        value: CurrencyFormatter.points(e.voteCount),
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Về tác phẩm', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 6),
                Text(e.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: 24),
                if (e.hasVoted)
                  const CustomButton(label: 'Bạn đã bình chọn tác phẩm này', icon: Icons.check_circle_rounded, onPressed: null)
                else
                  CustomButton(
                    label: state.contest!.canVote ? 'Bình chọn tác phẩm' : 'Bình chọn đã đóng',
                    icon: Icons.how_to_vote_rounded,
                    gold: true,
                    isLoading: voting,
                    onPressed: state.contest!.canVote ? () => voteForEntry(context, e) : null,
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => shareEntry(context, e),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Chia sẻ để kêu gọi bình chọn'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value, this.color = AppColors.primaryTeal});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}
