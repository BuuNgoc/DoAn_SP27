import 'package:flutter/widgets.dart';

import '../../core/config/app_config.dart';
import '../../core/localization/app_localizations.dart';

/// Model & Helper hỗ trợ dữ liệu đa ngôn ngữ dạng Map (LI-06: vi, en, ko, zh).
///
/// Quy tắc fallback chuẩn:
/// `locale hiện tại` → `'vi'` → `'en'` → chuỗi không rỗng đầu tiên → `''`.
class LocalizedTextModel {
  final String vi;
  final String en;
  final String ko;
  final String zh;

  const LocalizedTextModel({
    required this.vi,
    required this.en,
    required this.ko,
    required this.zh,
  });

  factory LocalizedTextModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LocalizedTextModel(vi: '', en: '', ko: '', zh: '');
    }
    return LocalizedTextModel(
      vi: (map['vi'] as String?)?.trim() ?? '',
      en: (map['en'] as String?)?.trim() ?? '',
      ko: (map['ko'] as String?)?.trim() ?? '',
      zh: (map['zh'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vi': vi,
      'en': en,
      'ko': ko,
      'zh': zh,
    };
  }

  /// Lấy văn bản theo mã ngôn ngữ (`vi`, `en`, `ko`, `zh`) với fallback `vi → en`.
  String getLocalized([String? languageCode]) {
    final code = (languageCode ??
            AppLocalizations.current?.locale.languageCode ??
            AppConfig.defaultLanguage)
        .toLowerCase();

    final primary = switch (code) {
      'en' => en,
      'ko' => ko,
      'zh' => zh,
      'vi' => vi,
      _ => vi,
    };

    if (primary.isNotEmpty) return primary;
    if (vi.isNotEmpty) return vi;
    if (en.isNotEmpty) return en;
    if (ko.isNotEmpty) return ko;
    if (zh.isNotEmpty) return zh;
    return '';
  }

  /// Lấy văn bản trực tiếp theo `Locale` của `BuildContext` hiện tại.
  String of(BuildContext context) =>
      getLocalized(Localizations.localeOf(context).languageCode);

  /// Helper tĩnh lấy text đa ngữ trực tiếp từ `Map<String, dynamic>?` (LI-06)
  /// theo locale hiện tại với fallback `vi → en`.
  static String fromLocalizedMap(
    Map<String, dynamic>? map, {
    String? languageCode,
    BuildContext? context,
  }) {
    if (map == null || map.isEmpty) return '';
    final resolvedCode = languageCode ??
        (context != null ? Localizations.localeOf(context).languageCode : null) ??
        AppLocalizations.current?.locale.languageCode ??
        AppConfig.defaultLanguage;
    return LocalizedTextModel.fromMap(map).getLocalized(resolvedCode);
  }
}

/// Extension tiện ích trên `Map<String, dynamic>?` cho dữ liệu Firestore đa ngữ (LI-06).
extension LocalizedTextMapX on Map<String, dynamic>? {
  /// Lấy chuỗi theo ngôn ngữ của `BuildContext` hiện tại (fallback `vi → en`).
  String localized(BuildContext context) =>
      LocalizedTextModel.fromLocalizedMap(this, context: context);

  /// Lấy chuỗi theo mã ngôn ngữ hoặc ngôn ngữ toàn cục hiện hành (fallback `vi → en`).
  String localizedByCode([String? languageCode]) =>
      LocalizedTextModel.fromLocalizedMap(this, languageCode: languageCode);
}
