import 'package:equatable/equatable.dart';

/// [FE-07] Entity for Booking Management (Create/Confirm/Cancel Booking, Booking History)
class BookingEntity extends Equatable {
  final String id;
  final String title;

  const BookingEntity({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}
