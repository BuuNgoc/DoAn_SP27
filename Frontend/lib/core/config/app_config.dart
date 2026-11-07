/// Cấu hình chạy ứng dụng.
///
/// `useMockBackend = true`: mọi DataSource dùng dữ liệu mẫu Ngũ Hành Sơn trong
/// bộ nhớ (kèm độ trễ giả lập) để ứng dụng chạy được ngay, không cần dự án
/// Firebase thật. Khi đã có `firebase_options.dart` thật, đổi sang `false` để
/// các DataSource gọi Firestore / Cloud Functions.
class AppConfig {
  AppConfig._();

  static const bool useMockBackend = false;

  /// Độ trễ giả lập của mạng khi chạy dữ liệu mẫu.
  static const Duration mockLatency = Duration(milliseconds: 450);

  /// Ngôn ngữ nội dung mặc định (LI: hỗ trợ vi, en, ko, zh).
  static const String defaultLanguage = 'vi';
  static const List<String> supportedLanguages = ['vi', 'en', 'ko', 'zh'];
}

/// Giả lập độ trễ mạng cho các DataSource mẫu.
Future<void> simulateLatency([Duration? duration]) =>
    Future<void>.delayed(duration ?? AppConfig.mockLatency);
