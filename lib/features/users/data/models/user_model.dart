/// Data model for API user (JSON ↔ model). No Flutter/Hive.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String? phone;
  final String? department;
  final String? employeeId;

  const UserModel({
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

  factory UserModel.fromApiMap(Map<String, dynamic> json) {
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final createdAtRaw = json['createdAt'];
    final createdAt = createdAtRaw != null
        ? (DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now())
        : null;
    final lastLoginRaw = json['lastLoginAt'];
    final lastLoginAt = lastLoginRaw != null
        ? DateTime.tryParse(lastLoginRaw.toString())
        : null;
    final roleStr = (json['role']?.toString() ?? 'employee').toLowerCase();
    return UserModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: roleStr,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      employeeId: json['employeeId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'phone': phone,
      'department': department,
      'employeeId': employeeId,
    };
  }
}
