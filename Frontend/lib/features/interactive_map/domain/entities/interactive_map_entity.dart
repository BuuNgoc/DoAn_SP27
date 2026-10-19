import 'package:equatable/equatable.dart';

/// [FE-04] Entity for Interactive Tourism Map (Google Maps, POI Markers, Category Filters, Directions)
class PoiLocationEntity extends Equatable {
  final String id;
  final String title;

  const PoiLocationEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
