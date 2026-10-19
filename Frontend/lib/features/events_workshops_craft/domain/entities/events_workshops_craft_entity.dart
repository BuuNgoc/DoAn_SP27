import 'package:equatable/equatable.dart';

/// [FE-06, FE-15, FE-16] Entity for Events, Non Nuoc Workshops, Artisans, Stone Carving Contest Voting
class EventCraftEntity extends Equatable {
  final String id;
  final String title;

  const EventCraftEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
