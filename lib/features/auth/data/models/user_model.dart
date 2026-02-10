import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';

/// User model for API response mapping
/// Maps JSON response from REST API to UserEntity
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    required super.accountType,
    super.role,
    super.companyId,
    super.companyName,
    super.isVerified,
    super.isActive,
    super.createdAt,
    super.lastLogin,
  });

  /// Create UserModel from JSON response
  /// Handles nested 'user' object from API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct user object and nested user object
    final userData = json['user'] as Map<String, dynamic>? ?? json;

    // Handle company data if present
    final company = userData['company'] as Map<String, dynamic>?;

    return UserModel(
      id: userData['_id']?.toString() ?? userData['id']?.toString() ?? '',
      email: userData['email'] as String? ?? '',
      name: userData['name'] as String? ?? '',
      phone: userData['phone'] as String?,
      accountType: userData['accountType'] as String? ?? 'personal',
      role: userData['role'] as String?,
      companyId:
          company?['_id']?.toString() ??
          company?['id']?.toString() ??
          userData['companyId']?.toString(),
      companyName:
          company?['name'] as String? ?? userData['companyName'] as String?,
      isVerified: userData['isVerified'] as bool? ?? false,
      isActive: userData['isActive'] as bool? ?? true,
      createdAt: _parseDateTime(userData['createdAt']),
      lastLogin: _parseDateTime(userData['lastLogin']),
    );
  }

  /// Parse datetime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Convert UserModel to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      'accountType': accountType,
      if (role != null) 'role': role,
      if (companyId != null) 'companyId': companyId,
      if (companyName != null) 'companyName': companyName,
      'isVerified': isVerified,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
    };
  }

  /// Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      accountType: accountType,
      role: role,
      companyId: companyId,
      companyName: companyName,
      isVerified: isVerified,
      isActive: isActive,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      accountType: entity.accountType,
      role: entity.role,
      companyId: entity.companyId,
      companyName: entity.companyName,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
    );
  }
}

/// Auth response model containing user data and token
class AuthResponseModel {
  final UserModel user;
  final String token;
  final String? message;

  const AuthResponseModel({
    required this.user,
    required this.token,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json),
      token: json['token'] as String? ?? '',
      message: json['message'] as String?,
    );
  }
}
