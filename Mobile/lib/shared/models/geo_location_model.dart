import 'package:cloud_firestore/cloud_firestore.dart';

class GeoLocationModel {
  final GeoPoint geoPoint;
  final String? geohash;
  final String address;

  const GeoLocationModel({
    required this.geoPoint,
    this.geohash,
    required this.address,
  });

  factory GeoLocationModel.fromMap(Map<String, dynamic> map) {
    return GeoLocationModel(
      geoPoint: map['geopoint'] as GeoPoint? ?? const GeoPoint(16.0028, 108.2618),
      geohash: map['geohash'] as String?,
      address: map['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'geopoint': geoPoint,
      'geohash': geohash,
      'address': address,
    };
  }
}
