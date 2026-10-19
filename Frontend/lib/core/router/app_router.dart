import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/destination_discovery/presentation/screens/destination_discovery_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/vr360_audio_guide/presentation/screens/vr360_audio_guide_screen.dart';
import '../../features/interactive_map/presentation/screens/interactive_map_screen.dart';
import '../../features/ai_travel_assistant/presentation/screens/ai_travel_assistant_screen.dart';
import '../../features/events_workshops_craft/presentation/screens/events_workshops_craft_screen.dart';
import '../../features/booking_management/presentation/screens/booking_management_screen.dart';
import '../../features/qr_checkin_loyalty/presentation/screens/qr_checkin_loyalty_screen.dart';
import '../../features/reviews_social_sharing/presentation/screens/reviews_social_sharing_screen.dart';
import '../../features/specialized_zones/presentation/screens/specialized_zones_screen.dart';
import '../../features/admin_portal/presentation/screens/admin_portal_screen.dart';

/// GoRouter configuration with role checking (LI-02, LI-07)
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const DestinationDiscoveryScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.vr360Viewer,
        builder: (context, state) => const Vr360AudioGuideScreen(),
      ),
      GoRoute(
        path: RouteNames.map,
        builder: (context, state) => const InteractiveMapScreen(),
      ),
      GoRoute(
        path: RouteNames.assistant,
        builder: (context, state) => const AiTravelAssistantScreen(),
      ),
      GoRoute(
        path: RouteNames.events,
        builder: (context, state) => const EventsWorkshopsCraftScreen(),
      ),
      GoRoute(
        path: RouteNames.bookingHistory,
        builder: (context, state) => const BookingManagementScreen(),
      ),
      GoRoute(
        path: RouteNames.qrScanner,
        builder: (context, state) => const QrCheckinLoyaltyScreen(),
      ),
      GoRoute(
        path: RouteNames.anThuongHub,
        builder: (context, state) => const SpecializedZonesScreen(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminPortalScreen(),
      ),
    ],
  );
}
