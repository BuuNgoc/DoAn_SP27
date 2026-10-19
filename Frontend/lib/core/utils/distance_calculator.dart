import 'dart:math';

/// Calculates distance between coordinates in meters using Haversine formula
class DistanceCalculator {
  static double calculateDistanceInMeters(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a));
  }
}
