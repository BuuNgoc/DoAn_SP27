import 'package:equatable/equatable.dart';

/// Ba vai trò hệ thống trong SmartTravel (RBAC - LI-02)
enum UserRole {
  tourist('TOURIST', 'Du khách'),
  tourismManager('TOURISM_MANAGER', 'Quản lý du lịch'),
  admin('ADMIN', 'Quản trị viên');

  const UserRole(this.code, this.label);
  final String code;
  final String label;

  static UserRole fromCode(String? code) =>
      UserRole.values.firstWhere((r) => r.code == code, orElse: () => UserRole.tourist);
}

/// [FE-01] Thực thể người dùng chuẩn Clean Architecture.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber = '',
    this.avatarUrl,
    this.role = 'TOURIST',
    this.loyaltyPoints = 0,
    this.totalEarnedPoints = 0,
    this.favoriteDestinationIds = const [],
    this.isActive = true,
    this.createdAt,
    this.nationality = 'Việt Nam',
    this.preferredLanguage = 'vi',
  });

  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final String role;
  final int loyaltyPoints;
  final int totalEarnedPoints;
  final List<String> favoriteDestinationIds;
  final bool isActive;
  final DateTime? createdAt;
  final String nationality;
  final String preferredLanguage;

  // Tiện ích kiểm tra vai trò RBAC
  bool get isAdmin => role == 'ADMIN';
  bool get isTourismManager => role == 'TOURISM_MANAGER' || isAdmin;
  bool get isTourist => role == 'TOURIST';

  // Getter hỗ trợ tương thích ngược với các phân hệ khác
  String get phone => phoneNumber;
  DateTime? get memberSince => createdAt;
  UserRole get roleEnum => UserRole.fromCode(role);

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[parts.length - 2][0] + parts.last[0]).toUpperCase();
  }

  UserEntity copyWith({
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
  }) {
    return UserEntity(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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

  @override
  List<Object?> get props => [
        uid,
        fullName,
        email,
        phoneNumber,
        avatarUrl,
        role,
        loyaltyPoints,
        totalEarnedPoints,
        favoriteDestinationIds,
        isActive,
        createdAt,
        nationality,
        preferredLanguage,
      ];
}

/// Bí danh tương thích ngược toàn dự án
typedef AppUser = UserEntity;
