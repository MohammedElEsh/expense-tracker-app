import 'package:equatable/equatable.dart';

/// User entity representing authenticated user from REST API
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String accountType; // 'personal' or 'business'
  final String? role; // 'owner', 'admin', 'employee' for business accounts
  final String? companyId;
  final String? companyName;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.accountType,
    this.role,
    this.companyId,
    this.companyName,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.lastLogin,
  });

  /// Check if user has a business account
  bool get isBusiness => accountType == 'business';

  /// Check if user has a personal account
  bool get isPersonal => accountType == 'personal';

  /// Get display name (uses name or email if name is empty)
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    accountType,
    role,
    companyId,
    companyName,
    isVerified,
    isActive,
    createdAt,
    lastLogin,
  ];

  @override
  String toString() =>
      'UserEntity(id: $id, email: $email, name: $name, accountType: $accountType)';

  /// Create a copy with updated fields
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? accountType,
    String? role,
    String? companyId,
    String? companyName,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      accountType: accountType ?? this.accountType,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
