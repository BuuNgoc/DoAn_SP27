import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase Cloud Messaging Service for push notifications [FE-07, FE-08]
class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    await _fcm.requestPermission();
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
