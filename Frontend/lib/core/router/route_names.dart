/// All GoRouter route names and paths mapping to FE-01 through FE-28
class RouteNames {
  RouteNames._();

  // Root & Shell
  static const String home = '/';
  static const String explore = '/explore';
  static const String map = '/map';
  static const String assistant = '/assistant';
  static const String profile = '/profile';

  // FE-01: Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';

  // FE-02: Destination Discovery
  static const String destinationDetails = '/destinations/:id';
  static const String destinationFavorites = '/favorites';

  // FE-03: VR360 & Audio Guide
  static const String vr360Viewer = '/vr360/:id';
  static const String audioPlayer = '/audio-guide/:id';

  // FE-04: Interactive Map
  static const String mapPoiDetails = '/map/poi/:id';

  // FE-05: AI Photo Recognition & RAG Itinerary
  static const String aiCamera = '/ai/camera';
  static const String aiItineraryResult = '/ai/itinerary-result';

  // FE-06, FE-15, FE-16: Events & Workshops & Stone Village
  static const String events = '/events';
  static const String eventDetails = '/events/:id';
  static const String workshops = '/workshops';
  static const String artisans = '/artisans';
  static const String stoneContest = '/stone-contest';

  // FE-07: Booking
  static const String createBooking = '/booking/create';
  static const String bookingHistory = '/booking/history';
  static const String bookingDetails = '/booking/:id';

  // FE-08, FE-09: QR Check-in & Loyalty
  static const String qrScanner = '/checkin/scan';
  static const String checkinHistory = '/checkin/history';
  static const String loyaltyRewards = '/loyalty/rewards';
  static const String rewardRedemptions = '/loyalty/redemptions';

  // FE-10, FE-11: Reviews & Social Share
  static const String writeReview = '/reviews/write/:destinationId';

  // FE-12, FE-13, FE-14: Specialized Zones
  static const String anThuongHub = '/zones/an-thuong';
  static const String beachSafety = '/zones/beach-safety';
  static const String airportPromos = '/zones/airport-promos';

  // FE-17 -> FE-28: Admin Portal
  static const String adminDashboard = '/admin/dashboard';
  static const String adminDestinations = '/admin/destinations';
  static const String adminEvents = '/admin/events';
  static const String adminLoyalty = '/admin/loyalty';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminAuditLogs = '/admin/audit-logs';
}
