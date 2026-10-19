import '../../domain/entities/auth_entity.dart';

/// [FE-01] Data Model with Firestore serialization for Authentication (Register, Login, Reset/Change Password, Profile)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.title,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
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
