import 'package:geolocator/geolocator.dart';

/// Geolocator service for GPS position & anti-fraud check-in (LI-08)
class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Dịch vụ định vị GPS chưa được bật');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí GPS bị từ chối');
      }
    }
    return await Geolocator.getCurrentPosition();
  }
}
