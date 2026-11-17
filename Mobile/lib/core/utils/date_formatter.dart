import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _weekdayKeys = [
    'common.weekday_mon',
    'common.weekday_tue',
    'common.weekday_wed',
    'common.weekday_thu',
    'common.weekday_fri',
    'common.weekday_sat',
    'common.weekday_sun',
  ];

  static String formatFull(DateTime dateTime) => DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

  static String formatDateOnly(DateTime dateTime) => DateFormat('dd/MM/yyyy').format(dateTime);

  static String formatTime(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

  /// Ví dụ: "Thứ Bảy, 24/10/2026".
  static String formatWithWeekday(DateTime dateTime) =>
      '${AppLocalizations.trStatic(_weekdayKeys[dateTime.weekday - 1])}, ${formatDateOnly(dateTime)}';

  /// Ví dụ: "24 thg 10" (vi) / "24/10" (en) / "10월 24일" (ko) / "10月24日" (zh).
  static String formatShort(DateTime dateTime) => AppLocalizations.trStatic(
        'common.short_date',
        params: {
          'day': '${dateTime.day}',
          'month': '${dateTime.month}',
        },
      );

  static String relative(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return AppLocalizations.trStatic('common.just_now');
    if (diff.inHours < 1) {
      return AppLocalizations.trStatic(
        'common.minutes_ago',
        params: {'count': '${diff.inMinutes}'},
      );
    }
    if (diff.inDays < 1) {
      return AppLocalizations.trStatic(
        'common.hours_ago',
        params: {'count': '${diff.inHours}'},
      );
    }
    if (diff.inDays < 30) {
      return AppLocalizations.trStatic(
        'common.days_ago',
        params: {'count': '${diff.inDays}'},
      );
    }
    return formatDateOnly(dateTime);
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vnd = NumberFormat.decimalPattern('vi');

  /// 150000 → "150.000đ"; 0 → "Miễn phí" (đa ngữ).
  static String vnd(num amount) =>
      amount == 0 ? AppLocalizations.trStatic('common.free') : '${_vnd.format(amount)}đ';

  static String points(num value) => _vnd.format(value);
}
