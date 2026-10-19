import 'package:equatable/equatable.dart';

/// [FE-02] Entity for Destination Discovery (List, Search, Filter, Details, Cultural Info, Favorites)
class DestinationEntity extends Equatable {
  final String id;
  final String title;

  const DestinationEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
