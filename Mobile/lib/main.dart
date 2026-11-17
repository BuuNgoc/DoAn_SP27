import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/locale_cubit.dart';
import 'features/destination_discovery/data/datasources/destination_data_sources.dart';
import 'firebase_options.dart';

/// Điểm khởi chạy: SmartTravel – Nền tảng du lịch thông minh Ngũ Hành Sơn (nhóm SE13).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase serverless (LI-04). Ở chế độ dữ liệu mẫu, ứng dụng vẫn chạy khi chưa cấu hình Firebase.
  if (!AppConfig.useMockBackend) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Bỏ qua khởi tạo Firebase (đang dùng dữ liệu mẫu): $e');
    }
  }

  // Bộ nhớ đệm cục bộ cho chế độ ngoại tuyến – địa điểm yêu thích, xem gần đây (LI-05) & cài đặt đa ngôn ngữ (LI-06).
  await Hive.initFlutter();
  await FavoritesLocalDataSource.init();
  await RecentlyViewedLocalDataSource.init();
  await LocaleCubit.init();

  await initializeDateFormatting('vi');
  await di.initDependencyInjection();

  runApp(const SmartTravelApp());
}
