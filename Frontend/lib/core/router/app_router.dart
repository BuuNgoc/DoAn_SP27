import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_travel_assistant/presentation/screens/ai_assistant_hub_screen.dart';
import '../../features/ai_travel_assistant/presentation/screens/ai_photo_scan_screen.dart';
import '../../features/ai_travel_assistant/presentation/screens/ai_travel_chat_screen.dart';
import '../../features/ai_travel_assistant/presentation/screens/recognition_result_screen.dart';
import '../../features/ai_travel_assistant/presentation/screens/smart_itinerary_planner_screen.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_screens.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/booking_management/presentation/screens/booking_form_screen.dart';
import '../../features/booking_management/presentation/screens/booking_screens.dart';
import '../../features/destination_discovery/domain/entities/destination.dart';
import '../../features/destination_discovery/presentation/screens/destination_detail_screen.dart';
import '../../features/destination_discovery/presentation/screens/destination_list_screen.dart';
import '../../features/destination_discovery/presentation/screens/home_screen.dart';
import '../../features/destination_discovery/presentation/screens/saved_favorites_screen.dart';
import '../../features/events_workshops_craft/domain/entities/event_entities.dart';
import '../../features/events_workshops_craft/presentation/screens/contest_entry_detail_screen.dart';
import '../../features/events_workshops_craft/presentation/screens/craft_workshop_artisan_screen.dart';
import '../../features/events_workshops_craft/presentation/screens/event_workshop_detail_screen.dart';
import '../../features/events_workshops_craft/presentation/screens/event_workshop_list_screen.dart';
import '../../features/events_workshops_craft/presentation/screens/stone_carving_contest_screen.dart';
import '../../features/interactive_map/presentation/screens/interactive_map_screen.dart';
import '../../features/qr_checkin_loyalty/domain/entities/loyalty_entities.dart';
import '../../features/qr_checkin_loyalty/presentation/screens/checkin_loyalty_hub_screen.dart';
import '../../features/qr_checkin_loyalty/presentation/screens/checkin_screens.dart';
import '../../features/qr_checkin_loyalty/presentation/screens/loyalty_screens.dart';
import '../../features/qr_checkin_loyalty/presentation/screens/qr_scanner_screen.dart';
import '../../features/reviews_social_sharing/presentation/screens/destination_reviews_screen.dart';
import '../../features/reviews_social_sharing/presentation/screens/personal_reviews_screen.dart';
import '../../features/reviews_social_sharing/presentation/screens/write_edit_review_screen.dart';
import '../../features/specialized_zones/presentation/screens/airport_arrival_promo_screen.dart';
import '../../features/specialized_zones/presentation/screens/an_thuong_experience_hub_screen.dart';
import '../../features/specialized_zones/presentation/screens/beach_tourism_screen.dart';
import '../../features/vr360_audio_guide/presentation/screens/audio_guide_screen.dart';
import '../../features/vr360_audio_guide/presentation/screens/vr360_panorama_screen.dart';
import 'main_navigation_shell.dart';
import 'route_names.dart';

/// Cấu hình GoRouter cho ứng dụng di động (FE-01 → FE-16).
///
/// - 5 tab dùng [StatefulShellRoute.indexedStack] (giữ trạng thái từng tab).
/// - Màn hình chi tiết khai báo cấp gốc → hiển thị toàn màn hình, che thanh điều hướng.
/// - Đường dẫn cần đăng nhập ([RouteNames.requiresAuth]) tự chuyển về `/login?from=...`.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RouteNames.explore,
      refreshListenable: _StreamListenable(authCubit.stream),
      redirect: (context, state) {
        final location = state.uri.toString();
        final loggedIn = authCubit.state.isAuthenticated;

        // Điều hướng từ gốc '/' về trang chính '/explore'
        if (state.matchedLocation == '/') {
          return RouteNames.explore;
        }

        // Chưa đăng nhập mà truy cập đường dẫn được bảo vệ -> chuyển về /login
        if (!loggedIn && RouteNames.requiresAuth(state.matchedLocation)) {
          return Uri(path: RouteNames.login, queryParameters: {'from': location}).toString();
        }

        // Đã đăng nhập mà đang ở trang login hoặc register -> điều hướng về trang chính hoặc trang trước đó
        if (loggedIn && (state.matchedLocation == RouteNames.login || state.matchedLocation == RouteNames.register)) {
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            return from;
          }
          return RouteNames.explore;
        }
        return null;
      },
      errorBuilder: (context, state) => const _NotFoundScreen(),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => MainNavigationShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: RouteNames.explore, builder: (_, _) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouteNames.map, builder: (_, _) => const InteractiveMapScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouteNames.ai, builder: (_, _) => const AiAssistantHubScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouteNames.checkin, builder: (_, _) => const CheckinLoyaltyHubScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: RouteNames.profile, builder: (_, _) => const ProfileScreen()),
            ]),
          ],
        ),

        // ── FE-01 Auth ────────────────────────────────────────────────────
        GoRoute(
          path: RouteNames.login,
          builder: (_, s) => LoginScreen(redirectTo: s.uri.queryParameters['from']),
        ),
        GoRoute(path: RouteNames.register, builder: (_, _) => const RegisterScreen()),
        GoRoute(path: RouteNames.resetPassword, builder: (_, _) => const ResetPasswordScreen()),
        GoRoute(path: RouteNames.changePassword, builder: (_, _) => const ChangePasswordScreen()),
        GoRoute(path: RouteNames.editProfile, builder: (_, _) => const EditProfileScreen()),

        // ── FE-02 Destinations ────────────────────────────────────────────
        GoRoute(
          path: RouteNames.destinations,
          builder: (_, s) => DestinationListScreen(
            initialCategory: DestinationCategory.fromCode(s.uri.queryParameters['category']),
            autofocusSearch: s.uri.queryParameters['focus'] == '1',
          ),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => DestinationDetailScreen(destinationId: s.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(path: RouteNames.favorites, builder: (_, _) => const SavedFavoritesScreen()),

        // ── FE-03 VR360 & Audio Guide ─────────────────────────────────────
        GoRoute(
          path: '/vr360/:id',
          builder: (_, s) => Vr360PanoramaScreen(destinationId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: '/audio-guide/:id',
          builder: (_, s) => AudioGuideScreen(destinationId: s.pathParameters['id']!),
        ),

        // ── FE-05 AI ──────────────────────────────────────────────────────
        GoRoute(path: RouteNames.aiScan, builder: (_, _) => const AiPhotoScanScreen()),
        GoRoute(
          path: RouteNames.aiResult,
          builder: (_, s) => RecognitionResultScreen(args: s.extra is RecognitionResultArgs ? s.extra as RecognitionResultArgs : null),
        ),
        GoRoute(path: RouteNames.aiPlanner, builder: (_, _) => const SmartItineraryPlannerScreen()),
        GoRoute(
          path: RouteNames.aiChat,
          builder: (_, s) => AiTravelChatScreen(initialQuestion: s.extra is String ? s.extra as String : null),
        ),

        // ── FE-06, FE-15, FE-16 Events, Artisans, Contest ─────────────────
        GoRoute(
          path: RouteNames.events,
          builder: (_, s) {
            final kind = s.uri.queryParameters['kind'];
            return EventWorkshopListScreen(initialKind: kind == null ? null : EventKind.fromCode(kind));
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => EventWorkshopDetailScreen(eventId: s.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/artisans/:id',
          builder: (_, s) => CraftWorkshopArtisanScreen(artisanId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: RouteNames.contest,
          builder: (_, _) => const StoneCarvingContestScreen(),
          routes: [
            GoRoute(
              path: ':contestId/entries/:entryId',
              builder: (_, s) => ContestEntryDetailScreen(
                contestId: s.pathParameters['contestId']!,
                entryId: s.pathParameters['entryId']!,
              ),
            ),
          ],
        ),

        // ── FE-07 Booking ─────────────────────────────────────────────────
        GoRoute(
          path: '/booking/new/:serviceId',
          builder: (_, s) => BookingFormScreen(serviceId: s.pathParameters['serviceId']!),
        ),
        GoRoute(
          path: '/booking/confirmation/:id',
          builder: (_, s) => BookingConfirmationScreen(bookingId: s.pathParameters['id']!),
        ),
        GoRoute(
          path: RouteNames.bookingHistory,
          builder: (_, _) => const BookingHistoryScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => BookingDetailScreen(bookingId: s.pathParameters['id']!),
            ),
          ],
        ),

        // ── FE-08, FE-09 Check-in & Loyalty ───────────────────────────────
        GoRoute(path: RouteNames.qrScanner, builder: (_, _) => const QrScannerScreen()),
        GoRoute(path: RouteNames.checkinPoints, builder: (_, _) => const CheckinPointsScreen()),
        GoRoute(
          path: RouteNames.checkinConfirmation,
          builder: (_, s) => CheckinConfirmationScreen(result: s.extra is CheckinResult ? s.extra as CheckinResult : null),
        ),
        GoRoute(
          path: RouteNames.rewards,
          builder: (_, _) => const LoyaltyRewardsScreen(),
          routes: [
            GoRoute(path: ':id', builder: (_, s) => RewardDetailScreen(rewardId: s.pathParameters['id']!)),
          ],
        ),
        GoRoute(path: RouteNames.redemptionHistory, builder: (_, _) => const RedemptionHistoryScreen()),

        // ── FE-10, FE-11 Reviews ──────────────────────────────────────────
        GoRoute(
          path: '/reviews/:destinationId',
          builder: (_, s) => DestinationReviewsScreen(destinationId: s.pathParameters['destinationId']!),
          routes: [
            GoRoute(
              path: 'write',
              builder: (_, s) => WriteEditReviewScreen(
                destinationId: s.pathParameters['destinationId']!,
                reviewId: s.uri.queryParameters['reviewId'],
              ),
            ),
          ],
        ),
        GoRoute(path: RouteNames.myReviews, builder: (_, _) => const PersonalReviewsScreen()),

        // ── FE-12, FE-13, FE-14 Specialized Zones ─────────────────────────
        GoRoute(path: RouteNames.anThuong, builder: (_, _) => const AnThuongExperienceHubScreen()),
        GoRoute(path: RouteNames.beach, builder: (_, _) => const BeachTourismScreen()),
        GoRoute(
          path: RouteNames.airportWelcome,
          builder: (_, s) => AirportArrivalPromoScreen(campaignId: s.uri.queryParameters['campaign']),
        ),
      ],
    );
  }
}

/// Chuyển Stream (AuthCubit) thành Listenable để GoRouter tự đánh giá lại redirect.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.travel_explore_rounded, size: 56),
              const SizedBox(height: 12),
              const Text('Không tìm thấy trang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Đường dẫn có thể đã thay đổi hoặc không còn tồn tại.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => context.go(RouteNames.explore), child: const Text('Về trang Khám phá')),
            ],
          ),
        ),
      ),
    );
  }
}
