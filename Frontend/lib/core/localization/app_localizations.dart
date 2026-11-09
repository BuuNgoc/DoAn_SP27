import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';

/// Quản lý đa ngôn ngữ ứng dụng (LI-06: vi, en, ko, zh).
///
/// - Đọc dữ liệu dịch từ `assets/translations/{lang}.json`.
/// - Luôn nạp sẵn `vi.json` làm bộ đệm dự phòng (fallback): nếu một khóa
///   bị thiếu ở ngôn ngữ hiện tại sẽ tự động rơi về tiếng Việt, tuyệt đối
///   không crash và không hiển thị khóa thô lên giao diện.
class AppLocalizations {
  AppLocalizations(
    this.locale, {
    required Map<String, dynamic> localizedMap,
    required Map<String, dynamic> fallbackViMap,
  })  : _localizedMap = localizedMap,
        _fallbackViMap = fallbackViMap;

  final Locale locale;
  final Map<String, dynamic> _localizedMap;
  final Map<String, dynamic> _fallbackViMap;

  /// Bộ nhớ đệm các tệp JSON đã đọc từ assets để chuyển ngôn ngữ tức thì.
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Ngôn ngữ hiện hành mới nhất phục vụ các hàm tiện ích không có `BuildContext`
  /// (ví dụ: `Validators`, `DateFormatter`, `errorMessageOf`).
  static AppLocalizations? _current;
  static AppLocalizations? get current => _current;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales =>
      AppConfig.supportedLanguages.map(Locale.new).toList(growable: false);

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (instance != null) return instance;
    if (_current != null) return _current!;
    return AppLocalizations(
      const Locale(AppConfig.defaultLanguage),
      localizedMap: _cache[AppConfig.defaultLanguage] ?? const {},
      fallbackViMap: _cache[AppConfig.defaultLanguage] ?? const {},
    );
  }

  /// Tải trước tệp tiếng Việt và ngôn ngữ khởi đầu trước khi `runApp`.
  static Future<AppLocalizations> preload(Locale initialLocale) async {
    final fallbackMap = await _loadJson(AppConfig.defaultLanguage);
    final code = AppConfig.supportedLanguages.contains(initialLocale.languageCode)
        ? initialLocale.languageCode
        : AppConfig.defaultLanguage;
    final primaryMap = code == AppConfig.defaultLanguage
        ? fallbackMap
        : await _loadJson(code);
    final instance = AppLocalizations(
      Locale(code),
      localizedMap: primaryMap,
      fallbackViMap: fallbackMap,
    );
    _current = instance;
    return instance;
  }

  static Future<Map<String, dynamic>> _loadJson(String langCode) async {
    final cached = _cache[langCode];
    if (cached != null) return cached;
    try {
      final raw = await rootBundle.loadString('assets/translations/$langCode.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _cache[langCode] = decoded;
        return decoded;
      }
    } catch (e) {
      debugPrint('Không đọc được assets/translations/$langCode.json: $e');
    }
    return const {};
  }

  /// Dịch một khóa phân cấp dạng chấm (vd: `profile.title`, `common.confirm`).
  ///
  /// Thứ tự ưu tiên:
  /// 1. Bản dịch theo `locale.languageCode` hiện tại.
  /// 2. Bản dịch gốc tiếng Việt (`vi.json`).
  /// 3. Chuỗi `fallback` truyền vào (hoặc chuỗi thân thiện cuối cùng).
  String tr(
    String key, {
    Map<String, String>? params,
    String? fallback,
  }) {
    String? value = _lookup(_localizedMap, key);
    if (value == null || value.isEmpty) {
      value = _lookup(_fallbackViMap, key);
    }
    final resolved = (value == null || value.isEmpty)
        ? (fallback ?? _humanizeKey(key))
        : value;
    if (params != null && params.isNotEmpty) {
      var interpolated = resolved;
      params.forEach((k, v) {
        interpolated = interpolated.replaceAll('{$k}', v);
      });
      return interpolated;
    }
    return resolved;
  }

  /// Tiện ích dịch nhanh khi không có `BuildContext` (trong Validator / Formatter).
  static String trStatic(
    String key, {
    Map<String, String>? params,
    String? fallback,
  }) {
    final current = _current;
    if (current != null) {
      return current.tr(key, params: params, fallback: fallback);
    }
    final viMap = _cache[AppConfig.defaultLanguage] ?? const {};
    final lookedUp = _lookup(viMap, key);
    final resolved = (lookedUp == null || lookedUp.isEmpty)
        ? (fallback ?? _humanizeKey(key))
        : lookedUp;
    if (params != null && params.isNotEmpty) {
      var interpolated = resolved;
      params.forEach((k, v) {
        interpolated = interpolated.replaceAll('{$k}', v);
      });
      return interpolated;
    }
    return resolved;
  }

  static String? _lookup(Map<String, dynamic> source, String dottedKey) {
    final parts = dottedKey.split('.');
    dynamic cursor = source;
    for (final part in parts) {
      if (cursor is Map<String, dynamic> && cursor.containsKey(part)) {
        cursor = cursor[part];
      } else {
        return null;
      }
    }
    return cursor is String ? cursor : null;
  }

  static String _humanizeKey(String key) {
    final last = key.split('.').last.replaceAll('_', ' ').trim();
    if (last.isEmpty) return '';
    return last[0].toUpperCase() + last.substring(1);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppConfig.supportedLanguages.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      AppLocalizations.preload(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get languageCode => Localizations.localeOf(this).languageCode;

  String tr(
    String key, {
    Map<String, String>? params,
    String? fallback,
  }) =>
      AppLocalizations.of(this).tr(key, params: params, fallback: fallback);
}
