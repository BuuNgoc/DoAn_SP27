import '../localization/app_localizations.dart';

class Validators {
  Validators._();

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phone = RegExp(r'^(\+84|0)\d{9,10}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppLocalizations.trStatic('core.validation.email_required');
    if (!_email.hasMatch(v)) return AppLocalizations.trStatic('core.validation.email_invalid');
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppLocalizations.trStatic('core.validation.password_required');
    if (v.length < 6) return AppLocalizations.trStatic('core.validation.password_min_length');
    return null;
  }

  static String? required(String? value, String fieldName) {
    if ((value?.trim() ?? '').isEmpty) {
      return AppLocalizations.trStatic(
        'core.validation.field_required',
        params: {'field': fieldName},
      );
    }
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // không bắt buộc
    if (!_phone.hasMatch(v)) return AppLocalizations.trStatic('core.validation.phone_invalid');
    return null;
  }

  static bool isValidEmail(String email) => _email.hasMatch(email.trim());
  static bool isValidPassword(String password) => password.length >= 6;
}
