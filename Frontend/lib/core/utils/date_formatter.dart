import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _weekdays = [
    'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật',
  ];

  static String formatFull(DateTime dateTime) => DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

  static String formatDateOnly(DateTime dateTime) => DateFormat('dd/MM/yyyy').format(dateTime);

  static String formatTime(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

  /// Ví dụ: "Thứ Bảy, 24/10/2026".
  static String formatWithWeekday(DateTime dateTime) =>
      '${_weekdays[dateTime.weekday - 1]}, ${formatDateOnly(dateTime)}';

  /// Ví dụ: "24 thg 10".
  static String formatShort(DateTime dateTime) => '${dateTime.day} thg ${dateTime.month}';

  static String relative(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 30) return '${diff.inDays} ngày trước';
    return formatDateOnly(dateTime);
  }
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vnd = NumberFormat.decimalPattern('vi');

  /// 150000 → "150.000đ"; 0 → "Miễn phí".
  static String vnd(num amount) => amount == 0 ? 'Miễn phí' : '${_vnd.format(amount)}đ';

  static String points(num value) => _vnd.format(value);
}
