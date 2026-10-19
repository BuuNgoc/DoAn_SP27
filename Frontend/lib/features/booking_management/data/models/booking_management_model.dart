import '../../domain/entities/booking_management_entity.dart';

/// [FE-07] Data Model with Firestore serialization for Booking Management (Create/Confirm/Cancel Booking, Booking History)
class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.title,
  });

  factory BookingModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return BookingModel(
      id: documentId,
      title: data['title'] as String? ?? data['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
    };
  }
}
