import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/event_entities.dart';
import '../bloc/events_cubits.dart';

/// Gửi bình chọn kèm kiểm tra đăng nhập – dùng chung cho danh sách và chi tiết.
Future<void> voteForEntry(BuildContext context, ContestEntry entry) async {
  final cubit = context.read<ContestCubit>();
  final user = await requireLogin(context, reason: context.tr('contest.login_to_vote_reason'));
  if (user == null || !context.mounted) return;
  final error = await cubit.vote(entry.id, user.uid);
  if (!context.mounted) return;
  if (error != null) {
    showAppSnackBar(context, error, type: SnackType.warning);
  } else {
    showAppSnackBar(
      context,
      context.tr('contest.vote_thanks', params: {'title': entry.title}),
      type: SnackType.success,
    );
  }
}

void shareEntry(BuildContext context, ContestEntry entry) => SocialShareSheet.show(
      context,
      title: entry.title,
      message: context.tr(
        'contest.share_entry_message',
        params: {'title': entry.title, 'artist': entry.artistName},
      ),
    );

/// [FE-16] Cuộc thi điêu khắc đá: thông tin, tác phẩm dự thi, bình chọn, bảng xếp hạng.
class StoneCarvingContestScreen extends StatelessWidget {
  const StoneCarvingContestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.uid;
    return BlocProvider(
      create: (_) => sl<ContestCubit>()..load(userId: userId),
      child: DefaultTabController(
        length: 3,
        child: TopographicScaffold(
          seed: 17,
          appBar: CustomAppBar(
            title: context.tr('contest.title'),
            subtitle: context.tr('contest.subtitle'),
            bottom: TabBar(
              tabs: [
                Tab(text: context.tr('contest.tab_entries')),
                Tab(text: context.tr('contest.tab_leaderboard')),
                Tab(text: context.tr('contest.tab_rules')),
              ],
            ),
          ),
          body: BlocBuilder<ContestCubit, ContestState>(
            builder: (context, state) {
              if (state.status.isFailure && state.contest == null) {
                return ErrorViewWidget(
                  message: state.errorMessage ?? context.tr('contest.load_error'),
                  onRetry: () => context.read<ContestCubit>().load(userId: userId),
                );
              }
              if (state.contest == null) return const LoadingIndicator();
              return TabBarView(
                children: [
                  _EntriesTab(state: state),
                  _LeaderboardTab(state: state),
                  _RulesTab(contest: state.contest!),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContestHeader extends StatelessWidget {
  const _ContestHeader({required this.state});

  final ContestState state;

  @override
  Widget build(BuildContext context) {
    final c = state.contest!;
    final daysLeft = c.votingEndsAt.difference(DateTime.now()).inDays;
    return AppCard(
      gradient: AppColors.primaryGradient,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PillBadge(
                  label: c.status.label,
                  icon: Icons.how_to_vote_rounded,
                  color: AppColors.accentSoftGold,
                  background: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('contest.theme_prefix', params: {'theme': c.theme}),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  c.canVote
                      ? context.tr(
                          'contest.days_left_ends',
                          params: {
                            'days': '$daysLeft',
                            'date': DateFormatter.formatDateOnly(c.votingEndsAt),
                          },
                        )
                      : context.tr('contest.voting_closed'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(CurrencyFormatter.points(state.totalVotes),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              Text(
                context.tr('contest.votes_label'),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntriesTab extends StatelessWidget {
  const _EntriesTab({required this.state});

  final ContestState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          sliver: SliverToBoxAdapter(child: _ContestHeader(state: state)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 240,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            itemCount: state.entries.length,
            itemBuilder: (context, i) => _EntryCard(
              entry: state.entries[i],
              voting: state.votingEntryId == state.entries[i].id,
              canVote: state.contest!.canVote,
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.voting, required this.canVote});

  final ContestEntry entry;
  final bool voting;
  final bool canVote;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push(RouteNames.contestEntry(entry.contestId, entry.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CoverImage(source: entry.image, width: double.infinity, radius: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(entry.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(CurrencyFormatter.points(entry.voteCount),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    const Spacer(),
                    InkWell(
                      onTap: () => shareEntry(context, entry),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.share_rounded, size: 18, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
            child: SizedBox(
              width: double.infinity,
              height: 38,
              child: entry.hasVoted
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(context.tr('contest.voted_btn')),
                    )
                  : FilledButton.icon(
                      onPressed: !canVote || voting ? null : () => voteForEntry(context, entry),
                      icon: voting
                          ? const SizedBox(
                              width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.how_to_vote_rounded, size: 18),
                      label: Text(context.tr('contest.vote_btn')),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  const _LeaderboardTab({required this.state});

  final ContestState state;

  @override
  Widget build(BuildContext context) {
    final total = state.totalVotes == 0 ? 1 : state.totalVotes;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: state.entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = state.entries[i];
        final medal = switch (i) {
          0 => const Color(0xFFE4B363),
          1 => const Color(0xFFB8C4C8),
          2 => const Color(0xFFD4A07A),
          _ => AppColors.backgroundSecondary,
        };
        return AppCard(
          padding: const EdgeInsets.all(12),
          onTap: () => context.push(RouteNames.contestEntry(e.contestId, e.id)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: medal,
                child: Text('${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: i < 3 ? Colors.white : AppColors.textSecondary,
                    )),
              ),
              const SizedBox(width: 10),
              CoverImage(source: e.image, width: 54, height: 54, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(e.artistName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: e.voteCount / total,
                        minHeight: 6,
                        color: i == 0 ? AppColors.accentSoftGold : AppColors.primaryPastel,
                        backgroundColor: AppColors.backgroundSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.points(e.voteCount), style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${(e.voteCount / total * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RulesTab extends StatelessWidget {
  const _RulesTab({required this.contest});

  final StoneCarvingContest contest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CoverImage(source: contest.coverImage, height: 170, width: double.infinity, radius: 0),
        ),
        const SizedBox(height: 14),
        Text(contest.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          context.tr('contest.organizer_prefix', params: {'organizer': contest.organizer}),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),
        const SizedBox(height: 10),
        Text(contest.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
        const SizedBox(height: 18),
        Text(context.tr('contest.prize_structure_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6),
        for (final p in contest.prizes)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.emoji_events_rounded, color: AppColors.accentSoftGold),
            title: Text(p),
          ),
        const SizedBox(height: 10),
        Text(context.tr('contest.voting_rules_title'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6),
        for (final r in contest.rules)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.rule_rounded, color: AppColors.primaryTeal),
            title: Text(r),
          ),
      ],
    );
  }
}
