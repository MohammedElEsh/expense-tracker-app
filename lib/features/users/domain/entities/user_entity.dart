import 'package:expense_tracker/features/users/domain/entities/user_role.dart';

/// Domain entity for a company user (business mode).
/// No Flutter or data layer imports.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? phone;
  final String? department;
  final String? employeeId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.lastLoginAt,
    this.phone,
    this.department,
    this.employeeId,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phone,
    String? department,
    String? employeeId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
    );
  }
}
