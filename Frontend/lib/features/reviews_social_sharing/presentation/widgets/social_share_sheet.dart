import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_feedback.dart';

/// [FE-11] Bảng chia sẻ điểm đến, sự kiện, thành tích check-in, phần thưởng
/// lên mạng xã hội (Facebook, Zalo, Messenger... qua bảng chia sẻ hệ thống).
class SocialShareSheet extends StatelessWidget {
  const SocialShareSheet({super.key, required this.title, required this.message});

  final String title;
  final String message;

  static Future<void> show(BuildContext context, {required String title, required String message}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surfaceWhite,
      builder: (_) => SocialShareSheet(title: title, message: message),
    );
  }

  Future<void> _systemShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    Navigator.pop(context);
    await SharePlus.instance.share(ShareParams(
      text: message,
      subject: title,
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  Future<void> _openUri(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.pop(context);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger?.showSnackBar(SnackBar(content: Text(AppLocalizations.trStatic('reviews.share_not_supported'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = <_ShareTarget>[
      _ShareTarget(context.tr('reviews.share_system_apps'), Icons.share_rounded, AppColors.primaryTeal, () => _systemShare(context)),
      _ShareTarget(
        context.tr('reviews.share_post_x'),
        Icons.alternate_email_rounded,
        AppColors.textPrimary,
        () => _openUri(context, Uri.https('twitter.com', '/intent/tweet', {'text': message})),
      ),
      _ShareTarget(
        context.tr('reviews.share_send_email'),
        Icons.mail_rounded,
        AppColors.warning,
        () => _openUri(context, Uri(scheme: 'mailto', queryParameters: {'subject': title, 'body': message})),
      ),
      _ShareTarget(context.tr('reviews.share_copy'), Icons.copy_rounded, AppColors.primaryPastel, () {
        Clipboard.setData(ClipboardData(text: message));
        showAppSnackBar(context, context.tr('reviews.share_copied'), type: SnackType.success);
        Navigator.pop(context);
      }),
    ];

    return SafeArea(
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
              Text(context.tr('reviews.share_with_friends'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(message,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in targets)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: t.onTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: t.color.withValues(alpha: 0.12),
                                child: Icon(t.icon, color: t.color),
                              ),
                              const SizedBox(height: 8),
                              Text(t.label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, height: 1.25)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareTarget {
  const _ShareTarget(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
