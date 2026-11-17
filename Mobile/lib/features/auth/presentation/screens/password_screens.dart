import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

/// [FE-01] Khôi phục mật khẩu qua Email
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final error = await context.read<AuthCubit>().resetPassword(_email.text);
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
    } else {
      setState(() => _sent = true);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr('auth.reset_email_sent_title'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('auth.reset_email_sent_body', params: {'email': _email.text.trim()}),
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.pop();
            },
            child: Text(context.tr('auth.back_to_login_understood')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthCubit c) => c.state.isSubmitting);

    return TopographicScaffold(
      seed: 11,
      appBar: const CustomAppBar(title: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          children: [
            AuthBrandHeader(
              title: context.tr('auth.forgot_password_title'),
              subtitle: context.tr('auth.forgot_password_subtitle'),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _sent
                    ? Column(
                        key: const ValueKey('sent'),
                        children: [
                          const Icon(Icons.mark_email_read_rounded, size: 58, color: AppColors.success),
                          const SizedBox(height: 14),
                          Text(
                            context.tr('auth.reset_email_sent_heading'),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('auth.reset_email_follow_instructions', params: {'email': _email.text.trim()}),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            label: context.tr('auth.back_to_login_screen'),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              decoration: InputDecoration(
                                labelText: context.tr('auth.registered_email'),
                                prefixIcon: const Icon(Icons.alternate_email_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              label: context.tr('auth.send_reset_link'),
                              icon: Icons.send_rounded,
                              isLoading: isSubmitting,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [FE-01] Đổi mật khẩu tài khoản
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final error = await context.read<AuthCubit>().changePassword(_current.text, _next.text);
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
      return;
    }

    showAppSnackBar(context, context.tr('auth.change_password_success'), type: SnackType.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthCubit c) => c.state.isSubmitting);

    return TopographicScaffold(
      appBar: CustomAppBar(title: context.tr('auth.change_password_title')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                PasswordField(
                  controller: _current,
                  label: context.tr('auth.current_password'),
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _next,
                  label: context.tr('auth.new_password'),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final base = Validators.password(v);
                    if (base != null) return base;
                    if (v == _current.text) return context.tr('auth.new_password_must_differ');
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _confirm,
                  label: context.tr('auth.confirm_new_password'),
                  validator: (v) => v != _next.text ? context.tr('core.validation.password_mismatch') : null,
                ),
                const SizedBox(height: 22),
                CustomButton(
                  label: context.tr('auth.update_password_button'),
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
