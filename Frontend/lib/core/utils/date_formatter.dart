import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDateOnly(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
