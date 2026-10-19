import 'package:equatable/equatable.dart';

/// [FE-03] Entity for VR360 & Audio Guide (360° Panorama Viewer, Multi-language Audio Player)
class Vr360AudioEntity extends Equatable {
  final String id;
  final String title;

  const Vr360AudioEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
