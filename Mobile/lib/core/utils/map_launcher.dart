import 'package:url_launcher/url_launcher.dart';

/// Mở Google Maps (ứng dụng hoặc trình duyệt) để chỉ đường đến tọa độ.
class MapLauncher {
  MapLauncher._();

  static Future<bool> openDirections({required double lat, required double lng, String? label}) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
