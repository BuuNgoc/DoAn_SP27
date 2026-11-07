import 'package:get_it/get_it.dart';

import '../../features/ai_travel_assistant/data/datasources/ai_remote_data_source.dart';
import '../../features/ai_travel_assistant/data/repositories/ai_assistant_repository_impl.dart';
import '../../features/ai_travel_assistant/domain/repositories/ai_assistant_repository.dart';
import '../../features/ai_travel_assistant/domain/usecases/ai_usecases.dart';
import '../../features/ai_travel_assistant/presentation/bloc/ai_cubits.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/booking_management/data/datasources/booking_remote_data_source.dart';
import '../../features/booking_management/data/repositories/booking_repository_impl.dart';
import '../../features/booking_management/domain/repositories/booking_repository.dart';
import '../../features/booking_management/domain/usecases/booking_usecases.dart';
import '../../features/booking_management/presentation/bloc/booking_cubits.dart';
import '../../features/destination_discovery/data/datasources/destination_data_sources.dart';
import '../../features/destination_discovery/data/repositories/destination_repository_impl.dart';
import '../../features/destination_discovery/domain/repositories/destination_repository.dart';
import '../../features/destination_discovery/domain/usecases/destination_usecases.dart';
import '../../features/destination_discovery/presentation/bloc/destination_cubits.dart';
import '../../features/events_workshops_craft/data/datasources/events_remote_data_source.dart';
import '../../features/events_workshops_craft/data/repositories/events_repository_impl.dart';
import '../../features/events_workshops_craft/domain/repositories/events_repository.dart';
import '../../features/events_workshops_craft/domain/usecases/events_usecases.dart';
import '../../features/events_workshops_craft/presentation/bloc/events_cubits.dart';
import '../../features/interactive_map/data/datasources/map_data_source.dart';
import '../../features/interactive_map/data/repositories/map_repository_impl.dart';
import '../../features/interactive_map/domain/repositories/map_repository.dart';
import '../../features/interactive_map/domain/usecases/get_map_pois_usecase.dart';
import '../../features/interactive_map/presentation/bloc/map_cubit.dart';
import '../../features/qr_checkin_loyalty/data/datasources/loyalty_remote_data_source.dart';
import '../../features/qr_checkin_loyalty/data/repositories/loyalty_repository_impl.dart';
import '../../features/qr_checkin_loyalty/domain/repositories/loyalty_repository.dart';
import '../../features/qr_checkin_loyalty/domain/usecases/loyalty_usecases.dart';
import '../../features/qr_checkin_loyalty/presentation/bloc/loyalty_cubit.dart';
import '../../features/reviews_social_sharing/data/datasources/review_remote_data_source.dart';
import '../../features/reviews_social_sharing/data/repositories/review_repository_impl.dart';
import '../../features/reviews_social_sharing/domain/repositories/review_repository.dart';
import '../../features/reviews_social_sharing/domain/usecases/review_usecases.dart';
import '../../features/reviews_social_sharing/presentation/bloc/review_cubits.dart';
import '../../features/specialized_zones/data/datasources/zone_remote_data_source.dart';
import '../../features/specialized_zones/data/repositories/zone_repository_impl.dart';
import '../../features/specialized_zones/domain/repositories/zone_repository.dart';
import '../../features/specialized_zones/domain/usecases/zone_usecases.dart';
import '../../features/specialized_zones/presentation/bloc/zone_cubits.dart';
import '../../features/vr360_audio_guide/data/datasources/vr360_audio_data_source.dart';
import '../../features/vr360_audio_guide/data/repositories/vr360_audio_repository_impl.dart';
import '../../features/vr360_audio_guide/domain/repositories/vr360_audio_repository.dart';
import '../../features/vr360_audio_guide/domain/usecases/vr360_audio_usecases.dart';
import '../../features/vr360_audio_guide/presentation/bloc/vr360_audio_cubits.dart';
import '../config/app_config.dart';
import '../network/connectivity_cubit.dart';
import '../network/network_info.dart';

/// Service Locator toàn cục.
final GetIt sl = GetIt.instance;

/// Đăng ký phụ thuộc theo Clean Architecture:
/// DataSource (lazySingleton – giữ trạng thái dữ liệu mẫu) → Repository → UseCase → Cubit (factory).
/// Các Cubit toàn cục (Auth, Favorites, Loyalty, Connectivity) là lazySingleton.
Future<void> initDependencyInjection() async {
  const mock = AppConfig.useMockBackend;

  // ── Core ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ConnectivityCubit(sl()));

  // ── FE-01 Auth ────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: ['email', 'profile']));
  sl.registerLazySingleton<AuthFirebaseDataSource>(
      () => AuthFirebaseDataSourceImpl(googleSignIn: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetCurrentUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailPasswordUseCase(sl()));
  sl.registerLazySingleton(() => RegisterWithEmailPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton(() => AuthBloc(
        getCurrentUser: sl(),
        loginWithEmail: sl(),
        registerWithEmail: sl(),
        signInWithGoogle: sl(),
        resetPassword: sl(),
        changePassword: sl(),
        updateProfile: sl(),
        logout: sl(),
      ));

  sl.registerLazySingleton(() => AuthCubit(
        getCurrentUser: sl(),
        login: sl(),
        register: sl(),
        signInWithGoogle: sl(),
        resetPassword: sl(),
        changePassword: sl(),
        updateProfile: sl(),
        logout: sl(),
      ));

  // ── FE-02 Destination Discovery ───────────────────────────────────────
  sl.registerLazySingleton<DestinationRemoteDataSource>(
      () => mock ? MockDestinationRemoteDataSource() : FirestoreDestinationRemoteDataSource());
  sl.registerLazySingleton(() => FavoritesLocalDataSource());
  sl.registerLazySingleton<DestinationRepository>(() => DestinationRepositoryImpl(remote: sl(), favorites: sl()));
  sl.registerLazySingleton(() => GetDestinationsUseCase(sl()));
  sl.registerLazySingleton(() => GetDestinationDetailUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteIdsUseCase(sl()));
  sl.registerFactory(() => DestinationListCubit(sl()));
  sl.registerFactory(() => DestinationDetailCubit(sl()));
  sl.registerLazySingleton(() => FavoritesCubit(getIds: sl(), toggle: sl()));

  // ── FE-03 VR360 & Audio Guide ─────────────────────────────────────────
  sl.registerLazySingleton<Vr360AudioRemoteDataSource>(() => MockVr360AudioRemoteDataSource());
  sl.registerLazySingleton<Vr360AudioRepository>(() => Vr360AudioRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetVr360ScenesUseCase(sl()));
  sl.registerLazySingleton(() => GetAudioGuideUseCase(sl()));
  sl.registerFactory(() => Vr360Cubit(sl()));
  sl.registerFactory(() => AudioGuideCubit(sl()));

  // ── FE-04 Interactive Map ─────────────────────────────────────────────
  sl.registerLazySingleton<MapRemoteDataSource>(
      () => mock ? MockMapRemoteDataSource() : FirestoreMapRemoteDataSource());
  sl.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetMapPoisUseCase(sl()));
  sl.registerFactory(() => MapCubit(sl()));

  // ── FE-05 AI Travel Assistant (Photo Recognition, RAG Itinerary, Chat) ─
  sl.registerLazySingleton<AiRemoteDataSource>(createAiRemoteDataSource);
  sl.registerLazySingleton<AiAssistantRepository>(() => AiAssistantRepositoryImpl(sl()));
  sl.registerLazySingleton(() => RecognizeLandmarkUseCase(sl()));
  sl.registerLazySingleton(() => GenerateItineraryUseCase(sl()));
  sl.registerLazySingleton(() => SendChatMessageUseCase(sl()));
  sl.registerFactory(() => AiScanCubit(sl()));
  sl.registerFactory(() => ItineraryCubit(sl()));
  sl.registerFactory(() => AiChatCubit(sl()));

  // ── FE-06, FE-15, FE-16 Events, Workshops, Artisans, Contest ──────────
  sl.registerLazySingleton<EventsRemoteDataSource>(
      () => mock ? MockEventsRemoteDataSource() : FirestoreEventsRemoteDataSource());
  sl.registerLazySingleton<EventsRepository>(() => EventsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetEventsUseCase(sl()));
  sl.registerLazySingleton(() => GetEventDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetArtisanUseCase(sl()));
  sl.registerLazySingleton(() => GetArtisansUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveContestUseCase(sl()));
  sl.registerLazySingleton(() => GetContestEntriesUseCase(sl()));
  sl.registerLazySingleton(() => GetContestEntryUseCase(sl()));
  sl.registerLazySingleton(() => VoteContestEntryUseCase(sl()));
  sl.registerFactory(() => EventListCubit(sl()));
  sl.registerFactory(() => EventDetailCubit(sl()));
  sl.registerFactory(() => ArtisanCubit(sl(), sl()));
  sl.registerFactory(() => ContestCubit(sl(), sl(), sl()));

  // ── FE-07 Booking ─────────────────────────────────────────────────────
  sl.registerLazySingleton<BookingRemoteDataSource>(
      () => mock ? MockBookingRemoteDataSource() : FirestoreBookingRemoteDataSource());
  sl.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(remote: sl(), events: sl()));
  sl.registerLazySingleton(() => GetBookableServicesUseCase(sl()));
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingDetailUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerFactory(() => BookingFormCubit(sl(), sl()));
  sl.registerFactory(() => BookingHistoryCubit(sl()));
  sl.registerFactory(() => BookingDetailCubit(sl(), sl()));

  // ── FE-08, FE-09 QR Check-in & Loyalty ────────────────────────────────
  sl.registerLazySingleton<LoyaltyRemoteDataSource>(
      () => mock ? MockLoyaltyRemoteDataSource() : FirebaseLoyaltyRemoteDataSource());
  sl.registerLazySingleton<LoyaltyRepository>(() => LoyaltyRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCheckinPointsUseCase(sl()));
  sl.registerLazySingleton(() => GetCheckinHistoryUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => GetLoyaltySummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetRewardsUseCase(sl()));
  sl.registerLazySingleton(() => RedeemRewardUseCase(sl()));
  sl.registerLazySingleton(() => GetRedemptionsUseCase(sl()));
  sl.registerLazySingleton(() => LoyaltyCubit(
        getPoints: sl(),
        getHistory: sl(),
        checkIn: sl(),
        getSummary: sl(),
        getRewards: sl(),
        redeem: sl(),
        getRedemptions: sl(),
      ));

  // ── FE-10, FE-11 Reviews & Social Sharing ─────────────────────────────
  sl.registerLazySingleton<ReviewRemoteDataSource>(
      () => mock ? MockReviewRemoteDataSource() : FirestoreReviewRemoteDataSource());
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetDestinationReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetMyReviewsUseCase(sl()));
  sl.registerLazySingleton(() => GetReviewUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));
  sl.registerLazySingleton(() => DeleteReviewUseCase(sl()));
  sl.registerLazySingleton(() => ReportReviewUseCase(sl()));
  sl.registerFactory(() => DestinationReviewsCubit(getReviews: sl(), delete: sl(), report: sl()));
  sl.registerFactory(() => MyReviewsCubit(getMine: sl(), delete: sl()));
  sl.registerFactory(() => WriteReviewCubit(getReview: sl(), submit: sl()));

  // ── FE-12, FE-13, FE-14 Specialized Zones ─────────────────────────────
  sl.registerLazySingleton<ZoneRemoteDataSource>(
      () => mock ? MockZoneRemoteDataSource() : FirestoreZoneRemoteDataSource());
  sl.registerLazySingleton<ZoneRepository>(() => ZoneRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetZoneOverviewUseCase(sl()));
  sl.registerLazySingleton(() => GetAirportWelcomeUseCase(sl()));
  sl.registerFactory(() => ZoneCubit(getOverview: sl(), getEvents: sl()));
  sl.registerFactory(() => AirportWelcomeCubit(getWelcome: sl(), getDestinations: sl(), getEvents: sl()));
}
