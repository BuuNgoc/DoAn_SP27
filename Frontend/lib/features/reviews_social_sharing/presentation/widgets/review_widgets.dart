import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../domain/entities/review.dart';

/// Thẻ thống kê điểm đánh giá (trung bình + phân bố 5 → 1 sao).
class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({super.key, required this.summary, this.selectedStar, this.onStarTap});

  final ReviewSummary summary;
  final int? selectedStar;
  final ValueChanged<int>? onStarTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Column(
              children: [
                Text(summary.average.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 4),
                RatingStars(rating: summary.average, size: 15),
                const SizedBox(height: 6),
                Text(context.tr('reviews.total_reviews_count', params: {'total': '${summary.total}'}),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onStarTap == null ? null : () => onStarTap!(star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                      child: Row(
                        children: [
                          Text('$star',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selectedStar == star ? AppColors.primaryTeal : AppColors.textSecondary,
                              )),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.accentSoftGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: summary.ratioOf(star),
                                minHeight: 7,
                                color: selectedStar == star ? AppColors.primaryTeal : AppColors.accentSoftGold,
                                backgroundColor: AppColors.backgroundSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 22,
                            child: Text('${summary.distribution[star] ?? 0}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ),
                        ],
                      ),
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

/// Thẻ hiển thị một đánh giá.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.isMine = false,
    this.showDestination = false,
    this.onEdit,
    this.onDelete,
    this.onReport,
    this.onDestinationTap,
  });

  final Review review;
  final bool isMine;
  final bool showDestination;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onDestinationTap;

  @override
  Widget build(BuildContext context) {
    final r = review;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDestination) ...[
            InkWell(
              onTap: onDestinationTap,
              child: Row(
                children: [
                  const Icon(Icons.place_rounded, size: 18, color: AppColors.primaryTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(r.destinationName,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
            const Divider(height: 20),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isMine ? AppColors.primaryTeal : AppColors.backgroundSecondary,
                child: Text(r.authorInitials,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isMine ? Colors.white : AppColors.primaryTeal,
                    )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(r.authorName,
                              overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        if (isMine) ...[
                          const SizedBox(width: 6),
                          PillBadge(label: context.tr('reviews.yours_badge'), fontSize: 10),
                        ],
                      ],
                    ),
                    Text(
                      [
                        if (r.authorNationality != null) localizedNationality(context, r.authorNationality!),
                        if (r.visitType != null) ReviewRules.localizedVisitType(context, r.visitType!),
                        DateFormatter.relative(r.createdAt),
                        if (r.isEdited) context.tr('reviews.edited_label'),
                      ].join(' · '),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _ReviewMenu(isMine: isMine, onEdit: onEdit, onDelete: onDelete, onReport: onReport),
            ],
          ),
          const SizedBox(height: 10),
          RatingStars(rating: r.rating.toDouble(), size: 17),
          const SizedBox(height: 8),
          Text(r.content, style: const TextStyle(height: 1.5)),
          if (r.photoCount > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in r.photos)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _openPhoto(context, CoverImage(source: p, radius: 0, fit: BoxFit.contain)),
                        child: CoverImage(source: p, width: 84, height: 84, radius: 14),
                      ),
                    ),
                  for (final b in r.localPhotos)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _openPhoto(context, Image.memory(b, fit: BoxFit.contain)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(b, width: 84, height: 84, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (r.helpfulCount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(context.tr('reviews.helpful_count', params: {'count': '${r.helpfulCount}'}),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _openPhoto(BuildContext context, Widget image) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            InteractiveViewer(child: Center(child: image)),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewMenu extends StatelessWidget {
  const _ReviewMenu({required this.isMine, this.onEdit, this.onDelete, this.onReport});
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final items = <PopupMenuEntry<String>>[
      if (isMine && onEdit != null)
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text(context.tr('common.edit')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (isMine && onDelete != null)
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            title: Text(context.tr('reviews.delete_review_menu'), style: const TextStyle(color: AppColors.error)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (!isMine && onReport != null)
        PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: const Icon(Icons.flag_outlined, color: AppColors.warning),
            title: Text(context.tr('reviews.report_violation_menu')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) => switch (v) {
        'edit' => onEdit?.call(),
        'delete' => onDelete?.call(),
        _ => onReport?.call(),
      },
      itemBuilder: (_) => items,
    );
  }
}

/// Hộp thoại "Báo cáo đánh giá vi phạm" – trả về lý do & ghi chú, hoặc null nếu hủy.
Future<({ReportReason reason, String? note})?> showReportReviewDialog(BuildContext context) {
  return showModalBottomSheet<({ReportReason reason, String? note})>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.surfaceWhite,
    builder: (_) => const _ReportSheet(),
  );
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet();

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason? _reason;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('reviews.report_sheet_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  context.tr('reviews.report_sheet_subtitle'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 10),
                for (final r in ReportReason.values)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      _reason == r ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: _reason == r ? AppColors.primaryTeal : AppColors.textMuted,
                    ),
                    title: Text(r.label, style: const TextStyle(fontSize: 14.5)),
                    onTap: () => setState(() => _reason = r),
                  ),
                const SizedBox(height: 6),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(hintText: context.tr('reviews.report_note_hint')),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error, minimumSize: const Size.fromHeight(50)),
                    onPressed: _reason == null
                        ? null
                        : () => Navigator.pop(context, (
                              reason: _reason!,
                              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
                            )),
                    icon: const Icon(Icons.flag_rounded),
                    label: Text(context.tr('reviews.send_report_btn')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
