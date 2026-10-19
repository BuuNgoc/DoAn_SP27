import 'package:equatable/equatable.dart';

/// [FE-12, FE-13, FE-14] Entity for Specialized Zones (An Thuong Hub, Beach Safety, Airport Promos)
class ZoneEntity extends Equatable {
  final String id;
  final String title;

  const ZoneEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
