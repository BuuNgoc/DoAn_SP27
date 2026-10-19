import 'package:equatable/equatable.dart';

/// [FE-01] Entity for Authentication (Register, Login, Reset/Change Password, Profile)
class UserEntity extends Equatable {
  final String id;
  final String title;

  const UserEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
