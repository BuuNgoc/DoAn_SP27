import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

/// [FE-01] Màn hình Đăng nhập (Email/Password & Đăng nhập bằng Google)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final error = await context.read<AuthCubit>().login(_email.text, _password.text);
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
      return;
    }

    showAppSnackBar(context, 'Chào mừng bạn quay lại SmartTravel!', type: SnackType.success);
    context.go(widget.redirectTo ?? RouteNames.explore);
  }

  Future<void> _submitGoogleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);

    final error = await context.read<AuthCubit>().signInWithGoogle();
    if (!mounted) return;

    setState(() => _isGoogleLoading = false);

    if (error != null) {
      if (!error.contains('hủy')) {
        showAppSnackBar(context, error, type: SnackType.error);
      }
      return;
    }

    showAppSnackBar(context, 'Đăng nhập bằng tài khoản Google thành công!', type: SnackType.success);
    context.go(widget.redirectTo ?? RouteNames.explore);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthCubit c) => c.state.isSubmitting);

    return TopographicScaffold(
      seed: 3,
      appBar: const CustomAppBar(title: ''),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            children: [
              const AuthBrandHeader(
                title: 'Đăng nhập',
                subtitle: 'Lưu địa điểm yêu thích, đặt workshop và tích điểm check-in.',
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PasswordField(
                        controller: _password,
                        validator: Validators.password,
                        onSubmitted: (_) => _submitEmailLogin(),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(RouteNames.resetPassword),
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                      CustomButton(
                        label: 'Đăng nhập',
                        isLoading: isSubmitting && !_isGoogleLoading,
                        onPressed: _isGoogleLoading ? null : _submitEmailLogin,
                      ),
                      const AuthOrDivider(text: 'Hoặc tiếp tục với'),
                      GoogleSignInButton(
                        label: 'Đăng nhập bằng Google',
                        isLoading: _isGoogleLoading,
                        onPressed: isSubmitting ? null : _submitGoogleLogin,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => context.push(RouteNames.register),
                    child: const Text('Đăng ký ngay'),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.go(RouteNames.explore),
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Tiếp tục khám phá với tư cách khách'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
