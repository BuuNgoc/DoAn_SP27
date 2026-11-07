import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../bloc/auth_cubit.dart';
import 'register_screen.dart' show kNationalities;

/// [FE-01] Màn hình Chỉnh sửa hồ sơ cá nhân & Cập nhật ảnh đại diện
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _languages = {'vi': 'Tiếng Việt', 'en': 'English', 'ko': '한국어', 'zh': '中文'};

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late String _nationality;
  late String _language;

  String? _pickedAvatarPath;
  bool _saving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? user?.phone ?? '');
    _nationality = kNationalities.contains(user?.nationality) ? user!.nationality : kNationalities.first;
    _language = _languages.containsKey(user?.preferredLanguage) ? user!.preferredLanguage : 'vi';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _chooseAvatarSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn ảnh đại diện',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryTeal),
                title: const Text('Chọn từ Thư viện ảnh'),
                onTap: () => Navigator.pop(bottomCtx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryTeal),
                title: const Text('Chụp ảnh mới bằng Camera'),
                onTap: () => Navigator.pop(bottomCtx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedAvatarPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Không thể chọn ảnh: ${e.toString()}', type: SnackType.error);
      }
    }
  }

  Future<void> _save() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final updatedUser = user.copyWith(
      fullName: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      nationality: _nationality,
      preferredLanguage: _language,
    );

    final error = await context.read<AuthCubit>().updateProfile(
          updatedUser,
          newAvatarFilePath: _pickedAvatarPath,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      showAppSnackBar(context, error, type: SnackType.error);
      return;
    }

    showAppSnackBar(context, 'Cập nhật hồ sơ thành công!', type: SnackType.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit c) => c.state.user);
    final currentAvatar = user?.avatarUrl;

    return TopographicScaffold(
      seed: 97,
      appBar: const CustomAppBar(title: 'Chỉnh sửa hồ sơ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: (_pickedAvatarPath == null && (currentAvatar == null || currentAvatar.isEmpty))
                            ? AppColors.primaryGradient
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _pickedAvatarPath != null
                            ? Image.file(
                                File(_pickedAvatarPath!),
                                fit: BoxFit.cover,
                                width: 96,
                                height: 96,
                              )
                            : (currentAvatar != null && currentAvatar.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: currentAvatar,
                                    fit: BoxFit.cover,
                                    width: 96,
                                    height: 96,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                                    ),
                                    errorWidget: (_, __, ___) => Center(
                                      child: Text(
                                        user?.initials ?? 'ST',
                                        style: const TextStyle(
                                          color: AppColors.primaryTeal,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      user?.initials ?? 'ST',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: AppColors.primaryTeal,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _chooseAvatarSource,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => Validators.required(v, 'họ và tên'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _nationality,
                      decoration: const InputDecoration(
                        labelText: 'Quốc tịch',
                        prefixIcon: Icon(Icons.public_rounded),
                      ),
                      items: [
                        for (final n in kNationalities) DropdownMenuItem(value: n, child: Text(n)),
                      ],
                      onChanged: (v) => setState(() => _nationality = v ?? _nationality),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _language,
                      decoration: const InputDecoration(
                        labelText: 'Ngôn ngữ thuyết minh ưu tiên',
                        prefixIcon: Icon(Icons.translate_rounded),
                      ),
                      items: [
                        for (final e in _languages.entries)
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                      ],
                      onChanged: (v) => setState(() => _language = v ?? _language),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Lưu thay đổi',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
