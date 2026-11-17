import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/auth_cubit.dart';
import '../widgets/auth_widgets.dart';

const kNationalities = ['Việt Nam', 'Hàn Quốc', 'Trung Quốc', 'Hoa Kỳ', 'Úc', 'Nhật Bản', 'Khác'];

String localizedNationality(BuildContext context, String raw) {
  return switch (raw) {
    'Việt Nam' => context.tr('auth.nationalities.vn'),
    'Hàn Quốc' => context.tr('auth.nationalities.kr'),
    'Trung Quốc' => context.tr('auth.nationalities.cn'),
    'Hoa Kỳ' => context.tr('auth.nationalities.us'),
    'Úc' => context.tr('auth.nationalities.au'),
    'Nhật Bản' => context.tr('auth.nationalities.jp'),
    'Khác' => context.tr('auth.nationalities.other'),
    _ => raw,
  };
}

/// [FE-01] Đăng ký tài khoản mới (Email & Google)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _nationality = kNationalities.first;
  bool _agreed = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitEmailRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      showAppSnackBar(
        context,
        context.tr('auth.agree_terms_warning'),
        type: SnackType.warning,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final error = await context.read<AuthCubit>().register(
          fullName: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
          nationality: _nationality,
        );
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
      return;
    }

    showAppSnackBar(
      context,
      context.tr('auth.register_success'),
      type: SnackType.success,
    );
    context.go(RouteNames.explore);
  }

  Future<void> _submitGoogleRegister() async {
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

    showAppSnackBar(
      context,
      context.tr('auth.google_register_success'),
      type: SnackType.success,
    );
    context.go(RouteNames.explore);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select((AuthCubit c) => c.state.isSubmitting);

    return TopographicScaffold(
      seed: 5,
      appBar: const CustomAppBar(title: ''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          children: [
            AuthBrandHeader(
              title: context.tr('auth.register_title'),
              subtitle: context.tr('auth.register_subtitle'),
            ),
            const SizedBox(height: 24),
            GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (v) => Validators.required(v, context.tr('auth.full_name_lower')),
                      decoration: InputDecoration(
                        labelText: context.tr('auth.full_name'),
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      decoration: InputDecoration(
                        labelText: context.tr('auth.email'),
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.phone,
                      decoration: InputDecoration(
                        labelText: context.tr('auth.phone_label'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _nationality,
                      decoration: InputDecoration(
                        labelText: context.tr('auth.nationality'),
                        prefixIcon: const Icon(Icons.public_rounded),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      items: [
                        for (final n in kNationalities)
                          DropdownMenuItem(
                            value: n,
                            child: Text(localizedNationality(context, n)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _nationality = v ?? _nationality),
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _password,
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _confirm,
                      label: context.tr('auth.confirm_password'),
                      validator: (v) => v != _password.text
                          ? context.tr('core.validation.password_mismatch')
                          : null,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primaryTeal,
                      title: Text(
                        context.tr('auth.agree_terms'),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      label: context.tr('auth.register_button'),
                      isLoading: isSubmitting && !_isGoogleLoading,
                      onPressed: _isGoogleLoading ? null : _submitEmailRegister,
                    ),
                    AuthOrDivider(text: context.tr('auth.or_register_with')),
                    GoogleSignInButton(
                      label: context.tr('auth.google_register'),
                      isLoading: _isGoogleLoading,
                      onPressed: isSubmitting ? null : _submitGoogleRegister,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.tr('auth.already_have_account'),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(context.tr('auth.login_now')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
