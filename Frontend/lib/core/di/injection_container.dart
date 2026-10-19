import 'package:get_it/get_it.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloud_functions_service.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';
import '../services/location_service.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

/// Central Dependency Injection Container for SmartTravel
Future<void> initDependencyInjection() async {
  // Core Services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<CloudFunctionsService>(() => CloudFunctionsService());
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<FCMService>(() => FCMService());
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Features DI registration stubs will be added per module
}
