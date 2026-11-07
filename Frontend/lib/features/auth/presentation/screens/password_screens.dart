import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Đã gửi email khôi phục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Liên kết đặt lại mật khẩu đã được gửi đến địa chỉ email:\n\n${_email.text.trim()}\n\n'
          'Vui lòng kiểm tra hộp thư đến (và thư mục Spam/Quảng cáo nếu cần) để hoàn tất việc đổi mật khẩu.',
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.pop();
            },
            child: const Text('Đã hiểu, quay lại đăng nhập'),
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
            const AuthBrandHeader(
              title: 'Quên mật khẩu',
              subtitle: 'Nhập email đã đăng ký tài khoản, chúng tôi sẽ gửi liên kết khôi phục mật khẩu.',
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
                          const Text(
                            'Email khôi phục đã được gửi!',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng làm theo hướng dẫn trong email gửi tới ${_email.text.trim()}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(label: 'Quay lại màn hình đăng nhập', onPressed: () => context.pop()),
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
                              decoration: const InputDecoration(
                                labelText: 'Email đã đăng ký',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomButton(
                              label: 'Gửi liên kết khôi phục',
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

    showAppSnackBar(context, 'Đổi mật khẩu thành công.', type: SnackType.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthCubit c) => c.state.isSubmitting);

    return TopographicScaffold(
      appBar: const CustomAppBar(title: 'Đổi mật khẩu'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                PasswordField(
                  controller: _current,
                  label: 'Mật khẩu hiện tại',
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _next,
                  label: 'Mật khẩu mới',
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final base = Validators.password(v);
                    if (base != null) return base;
                    if (v == _current.text) return 'Mật khẩu mới phải khác mật khẩu hiện tại.';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                PasswordField(
                  controller: _confirm,
                  label: 'Xác nhận lại mật khẩu mới',
                  validator: (v) => v != _next.text ? 'Mật khẩu xác nhận không trùng khớp.' : null,
                ),
                const SizedBox(height: 22),
                CustomButton(
                  label: 'Cập nhật mật khẩu',
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
