import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/app_config.dart';
import 'app_localizations.dart';

/// Thông tin mô tả một ngôn ngữ được hỗ trợ (LI-06).
class SupportedLanguageOption {
  const SupportedLanguageOption({
    required this.code,
    required this.flag,
    required this.nativeName,
    required this.titleKey,
  });

  final String code;
  final String flag;
  final String nativeName;
  final String titleKey;
}

/// Quản lý trạng thái ngôn ngữ toàn cục của ứng dụng (LI-06: vi, en, ko, zh).
///
/// - Lưu lựa chọn của người dùng vào Hive box `app_settings`.
/// - Khi khởi tạo lần đầu (chưa có lựa chọn trong Hive), ưu tiên ngôn ngữ của
///   thiết bị nếu thuộc danh sách hỗ trợ, ngược lại fallback về `'vi'`.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit([Locale? initialLocale])
      : super(initialLocale ?? resolveInitialLocale());

  static const String boxName = 'app_settings';
  static const String localeKey = 'language_code';

  static const List<SupportedLanguageOption> supportedOptions = [
    SupportedLanguageOption(
      code: 'vi',
      flag: '🇻🇳',
      nativeName: 'Tiếng Việt',
      titleKey: 'profile.lang_vi',
    ),
    SupportedLanguageOption(
      code: 'en',
      flag: '🇬🇧',
      nativeName: 'English',
      titleKey: 'profile.lang_en',
    ),
    SupportedLanguageOption(
      code: 'ko',
      flag: '🇰🇷',
      nativeName: '한국어',
      titleKey: 'profile.lang_ko',
    ),
    SupportedLanguageOption(
      code: 'zh',
      flag: '🇨🇳',
      nativeName: '中文',
      titleKey: 'profile.lang_zh',
    ),
  ];

  /// Mở Hive box lưu cài đặt ngôn ngữ và nạp sẵn dữ liệu dịch ban đầu.
  static Future<Locale> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
    final initial = resolveInitialLocale();
    await AppLocalizations.preload(initial);
    return initial;
  }

  /// Xác định ngôn ngữ khởi đầu:
  /// 1. Giá trị đã lưu trong Hive (nếu hợp lệ).
  /// 2. Ngôn ngữ hệ thống của thiết bị (nếu thuộc `vi`, `en`, `ko`, `zh`).
  /// 3. Fallback mặc định về `AppConfig.defaultLanguage` (`'vi'`).
  static Locale resolveInitialLocale() {
    if (Hive.isBoxOpen(boxName)) {
      final saved = Hive.box<String>(boxName).get(localeKey);
      if (saved != null && AppConfig.supportedLanguages.contains(saved)) {
        return Locale(saved);
      }
    }

    final deviceCode =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    if (AppConfig.supportedLanguages.contains(deviceCode)) {
      return Locale(deviceCode);
    }

    return const Locale(AppConfig.defaultLanguage);
  }

  String get currentLanguageCode => state.languageCode;

  SupportedLanguageOption get currentOption =>
      supportedOptions.firstWhere(
        (o) => o.code == state.languageCode,
        orElse: () => supportedOptions.first,
      );

  /// Đổi ngôn ngữ hiển thị, nạp tệp dịch và lưu vào Hive ngay lập tức.
  Future<void> setLocale(String languageCode) async {
    final normalized = languageCode.trim().toLowerCase();
    if (!AppConfig.supportedLanguages.contains(normalized)) return;

    final nextLocale = Locale(normalized);
    await AppLocalizations.preload(nextLocale);

    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<String>(boxName).put(localeKey, normalized);
    }

    if (state.languageCode != normalized) {
      emit(nextLocale);
    }
  }
}
