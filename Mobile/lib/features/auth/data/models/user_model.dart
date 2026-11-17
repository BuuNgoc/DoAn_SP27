import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

/// [FE-01] Model ánh xạ dữ liệu Firestore `users/{uid}` kế thừa `UserEntity`.
class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    String phoneNumber = '',
    String phone = '',
    super.avatarUrl,
    super.role = 'TOURIST',
    super.loyaltyPoints = 0,
    super.totalEarnedPoints = 0,
    super.favoriteDestinationIds = const [],
    super.isActive = true,
    DateTime? createdAt,
    DateTime? memberSince,
    super.nationality = 'Việt Nam',
    super.preferredLanguage = 'vi',
  }) : super(
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : phone,
          createdAt: createdAt ?? memberSince,
        );

  /// Chuyển đổi từ `UserEntity` sang `UserModel`
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      loyaltyPoints: entity.loyaltyPoints,
      totalEarnedPoints: entity.totalEarnedPoints,
      favoriteDestinationIds: entity.favoriteDestinationIds,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      nationality: entity.nationality,
      preferredLanguage: entity.preferredLanguage,
    );
  }

  /// Ánh xạ từ Firestore `DocumentSnapshot`
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel.fromMap(data, snapshot.id);
  }

  /// Ánh xạ từ Map dữ liệu Firestore
  factory UserModel.fromMap(Map<String, dynamic> data, [String? uid]) {
    final id = uid ?? data['uid'] as String? ?? '';
    final rawCreatedAt = data['createdAt'] ?? data['memberSince'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    final rawFavorites = data['favoriteDestinationIds'];
    final List<String> favorites = rawFavorites is List ? List<String>.from(rawFavorites) : const [];

    return UserModel(
      uid: id,
      fullName: data['fullName'] as String? ?? 'Du khách SmartTravel',
      email: data['email'] as String? ?? '',
      phoneNumber: (data['phoneNumber'] ?? data['phone']) as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      role: data['role'] as String? ?? 'TOURIST',
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
      totalEarnedPoints: (data['totalEarnedPoints'] as num?)?.toInt() ?? 0,
      favoriteDestinationIds: favorites,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: createdAt,
      nationality: data['nationality'] as String? ?? 'Việt Nam',
      preferredLanguage: data['preferredLanguage'] as String? ?? 'vi',
    );
  }

  /// Chuyển đổi toàn bộ model sang Map để lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'phone': phoneNumber, // Tương thích ngược
      'avatarUrl': avatarUrl,
      'role': role,
      'loyaltyPoints': loyaltyPoints,
      'totalEarnedPoints': totalEarnedPoints,
      'favoriteDestinationIds': favoriteDestinationIds,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'nationality': nationality,
      'preferredLanguage': preferredLanguage,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Các trường cơ bản được phép sửa từ phía client (không chạm đến role hay loyaltyPoints theo LI-07)
  Map<String, dynamic> toProfileUpdateMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'phone': phoneNumber,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'nationality': nationality,
      'preferredLanguage': preferredLanguage,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Phương thức tương thích ngược với code cũ
  Map<String, dynamic> toFirestoreProfileUpdate() => toProfileUpdateMap();

  @override
  UserModel copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    int? loyaltyPoints,
    int? totalEarnedPoints,
    List<String>? favoriteDestinationIds,
    bool? isActive,
    DateTime? createdAt,
    String? nationality,
    String? preferredLanguage,
    String? phone, // backward compatibility
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? phone ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalEarnedPoints: totalEarnedPoints ?? this.totalEarnedPoints,
      favoriteDestinationIds: favoriteDestinationIds ?? this.favoriteDestinationIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      nationality: nationality ?? this.nationality,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}
