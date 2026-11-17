/// Toàn bộ đường dẫn GoRouter của ứng dụng di động (FE-01 → FE-16).
class RouteNames {
  RouteNames._();

  // ── 5 tab của MainNavigationShell ─────────────────────────────────────
  static const String explore = '/explore'; // FE-02, 03, 06, 12, 13, 14
  static const String map = '/map'; // FE-04
  static const String ai = '/ai'; // FE-05 & RAG
  static const String checkin = '/checkin'; // FE-08, FE-09
  static const String profile = '/profile'; // FE-01, 07, 10, 11

  // ── FE-01: Authentication ─────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';

  // ── FE-02: Destination Discovery ──────────────────────────────────────
  static const String destinations = '/destinations';
  static String destinationDetail(String id) => '/destinations/$id';
  static const String favorites = '/favorites';

  // ── FE-03: VR360 & Audio Guide ────────────────────────────────────────
  static String vr360(String destinationId) => '/vr360/$destinationId';
  static String audioGuide(String destinationId) => '/audio-guide/$destinationId';

  // ── FE-05: AI Photo Recognition & RAG Itinerary ───────────────────────
  static const String aiScan = '/ai-scan';
  static const String aiResult = '/ai-result';
  static const String aiPlanner = '/ai-planner';
  static const String aiChat = '/ai-chat';

  // ── FE-06, FE-15, FE-16: Events, Workshops, Artisans, Contest ─────────
  static const String events = '/events';
  static String eventDetail(String id) => '/events/$id';
  static String artisan(String id) => '/artisans/$id';
  static const String contest = '/contest';
  static String contestEntry(String contestId, String entryId) => '/contest/$contestId/entries/$entryId';

  // ── FE-07: Booking ────────────────────────────────────────────────────
  static String bookingForm(String serviceId) => '/booking/new/$serviceId';
  static String bookingConfirmation(String bookingId) => '/booking/confirmation/$bookingId';
  static const String bookingHistory = '/bookings';
  static String bookingDetail(String id) => '/bookings/$id';

  // ── FE-08, FE-09: QR Check-in & Loyalty ───────────────────────────────
  static const String qrScanner = '/checkin-scan';
  static const String checkinPoints = '/checkin-points';
  static const String checkinConfirmation = '/checkin-confirmation';
  static const String rewards = '/rewards';
  static String rewardDetail(String id) => '/rewards/$id';
  static const String redemptionHistory = '/redemptions';

  // ── FE-10, FE-11: Reviews & Social Sharing ────────────────────────────
  static String destinationReviews(String destinationId) => '/reviews/$destinationId';
  static String writeReview(String destinationId) => '/reviews/$destinationId/write';
  static const String myReviews = '/my-reviews';

  // ── FE-12, FE-13, FE-14: Specialized Zones ────────────────────────────
  static const String anThuong = '/zones/an-thuong';
  static const String beach = '/zones/beach';
  static const String airportWelcome = '/welcome-airport';

  /// Các đường dẫn cần đăng nhập (chuyển hướng về `/login?from=...`).
  static const List<String> protectedPrefixes = [
    changePassword,
    editProfile,
    '/booking',
    bookingHistory,
    qrScanner,
    redemptionHistory,
    myReviews,
  ];

  static bool requiresAuth(String location) {
    if (location.startsWith('/reviews/') && location.endsWith('/write')) return true;
    return protectedPrefixes.any(location.startsWith);
  }
}
