import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/router/route_names.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

/// Trả về người dùng hiện tại; nếu chưa đăng nhập sẽ mời đăng nhập và trả về null.
Future<AppUser?> requireLogin(BuildContext context, {required String reason}) async {
  final auth = context.read<AuthCubit>().state;
  if (auth.isAuthenticated) return auth.user;

  final from = GoRouterState.of(context).uri.toString();
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      scrollable: true,
      icon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryTeal, size: 32),
      title: Text(ctx.tr('core.login_required_title')),
      content: Text(reason, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.tr('common.later')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ctx.tr('auth.login')),
        ),
      ],
    ),
  );
  if (go == true && context.mounted) {
    context.push('${RouteNames.login}?from=${Uri.encodeComponent(from)}');
  }
  return null;
}
