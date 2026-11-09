import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../destination_discovery/presentation/bloc/destination_cubits.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_cubits.dart';

/// [FE-10] Viết mới hoặc chỉnh sửa đánh giá (chấm sao, nội dung, ảnh thực tế).
class WriteEditReviewScreen extends StatelessWidget {
  const WriteEditReviewScreen({super.key, required this.destinationId, this.reviewId});

  final String destinationId;
  final String? reviewId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<WriteReviewCubit>()..init(destinationId, reviewId)),
        BlocProvider(create: (_) => sl<DestinationDetailCubit>()..load(destinationId)),
      ],
      child: BlocBuilder<WriteReviewCubit, WriteReviewState>(
        buildWhen: (a, b) => a.status != b.status,
        builder: (context, state) {
          final title = reviewId == null ? context.tr('reviews.write_review') : context.tr('reviews.edit_review_title');
          if (state.status.isLoading) {
            return TopographicScaffold(appBar: CustomAppBar(title: title), body: const LoadingIndicator());
          }
          if (state.status.isFailure) {
            return TopographicScaffold(
              appBar: CustomAppBar(title: title),
              body: ErrorViewWidget(message: state.errorMessage ?? context.tr('reviews.load_error')),
            );
          }
          return _ReviewForm(destinationId: destinationId, existing: state.existing, title: title);
        },
      ),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm({required this.destinationId, required this.existing, required this.title});
  final String destinationId;
  final Review? existing;
  final String title;

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  late int _rating = widget.existing?.rating ?? 0;
  late String? _visitType = widget.existing?.visitType;
  late final TextEditingController _content = TextEditingController(text: widget.existing?.content ?? '');
  late final List<String> _keptPhotos = [...?widget.existing?.photos];
  late final List<Uint8List> _newPhotos = [...?widget.existing?.localPhotos];
  final _picker = ImagePicker();

  int get _photoCount => _keptPhotos.length + _newPhotos.length;

  @override
  void initState() {
    super.initState();
    _content.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos(ImageSource source) async {
    final remaining = ReviewRules.maxPhotos - _photoCount;
    if (remaining <= 0) {
      showAppSnackBar(
        context,
        context.tr('reviews.max_photos_warning', params: {'max': '${ReviewRules.maxPhotos}'}),
        type: SnackType.warning,
      );
      return;
    }
    try {
      final files = source == ImageSource.camera
          ? [?await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1600)]
          : await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600, limit: remaining > 1 ? remaining : null);
      final bytes = <Uint8List>[];
      for (final f in files.take(remaining)) {
        bytes.add(await f.readAsBytes());
      }
      if (!mounted) return;
      setState(() => _newPhotos.addAll(bytes));
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, context.tr('reviews.photo_access_error'), type: SnackType.error);
      }
    }
  }

  Future<void> _submit() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;
    if (_rating == 0) {
      showAppSnackBar(context, context.tr('reviews.rate_star_warning'), type: SnackType.warning);
      return;
    }
    final destinationName =
        context.read<DestinationDetailCubit>().state.destination?.name ?? widget.existing?.destinationName ?? '';
    final error = await context.read<WriteReviewCubit>().submit(
          userId: user.uid,
          authorName: user.fullName,
          nationality: user.nationality,
          draft: ReviewDraft(
            reviewId: widget.existing?.id,
            destinationId: widget.destinationId,
            destinationName: destinationName,
            rating: _rating,
            content: _content.text,
            visitType: _visitType,
            keptPhotos: _keptPhotos,
            newPhotos: _newPhotos,
          ),
        );
    if (!mounted) return;
    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
      return;
    }
    showAppSnackBar(
      context,
      widget.existing == null ? context.tr('reviews.submit_thanks') : context.tr('reviews.update_success'),
      type: SnackType.success,
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final destination = context.select((DestinationDetailCubit c) => c.state.destination);
    final submitting = context.select((WriteReviewCubit c) => c.state.submitting);
    final length = _content.text.trim().length;
    return TopographicScaffold(
      seed: 67,
      appBar: CustomAppBar(title: widget.title),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (destination != null)
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CoverImage(source: destination.coverImage, width: 56, height: 56, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(destination.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(destination.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          Center(
            child: Text(context.tr('reviews.how_was_experience'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          StarRatingInput(value: _rating, onChanged: (v) => setState(() => _rating = v)),
          const SizedBox(height: 18),
          Text(context.tr('reviews.who_with'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in ReviewRules.visitTypes)
                ChoiceChip(
                  label: Text(ReviewRules.localizedVisitType(context, t)),
                  selected: _visitType == t,
                  onSelected: (s) => setState(() => _visitType = s ? t : null),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(context.tr('reviews.review_content_label'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _content,
            maxLines: 6,
            maxLength: ReviewRules.maxContentLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.tr('reviews.review_content_hint'),
            ),
          ),
          if (length > 0 && length < ReviewRules.minContentLength)
            Text(
              context.tr('reviews.need_more_chars', params: {'count': '${ReviewRules.minContentLength - length}'}),
              style: const TextStyle(color: AppColors.warning, fontSize: 12.5),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text(context.tr('reviews.real_photos_label'), style: const TextStyle(fontWeight: FontWeight.w700))),
              Text('$_photoCount/${ReviewRules.maxPhotos}', style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_photoCount < ReviewRules.maxPhotos) ...[
                  _AddPhotoTile(
                    icon: Icons.photo_library_rounded,
                    label: context.tr('reviews.gallery_btn'),
                    onTap: () => _pickPhotos(ImageSource.gallery),
                  ),
                  _AddPhotoTile(
                    icon: Icons.photo_camera_rounded,
                    label: context.tr('ai.take_photo'),
                    onTap: () => _pickPhotos(ImageSource.camera),
                  ),
                ],
                for (var i = 0; i < _keptPhotos.length; i++)
                  _PhotoThumb(
                    image: CoverImage(source: _keptPhotos[i], width: 92, height: 92, radius: 16),
                    onRemove: () => setState(() => _keptPhotos.removeAt(i)),
                  ),
                for (var i = 0; i < _newPhotos.length; i++)
                  _PhotoThumb(
                    image: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_newPhotos[i], width: 92, height: 92, fit: BoxFit.cover),
                    ),
                    onRemove: () => setState(() => _newPhotos.removeAt(i)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('reviews.community_guidelines'),
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: widget.existing == null ? context.tr('reviews.submit_review_btn') : context.tr('auth.save_changes'),
            icon: Icons.send_rounded,
            isLoading: submitting,
            onPressed: _rating > 0 && length >= ReviewRules.minContentLength ? _submit : null,
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 92,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryPastel.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primaryTeal),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.image, required this.onRemove});
  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          image,
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close_rounded, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
