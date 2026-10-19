import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart' as di;
import 'app.dart';

/// App Entry Point: SmartTravel - Smart Tourism Platform for Ngu Hanh Son
/// Group SE13 - FPT University Da Nang
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Serverless Services (LI-04)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Local Cache (Hive) for Offline Persistence (LI-05)
  await Hive.initFlutter();

  // Initialize Dependency Injection
  await di.initDependencyInjection();

  runApp(const SmartTravelApp());
}
