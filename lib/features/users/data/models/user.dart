import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

/// أدوار المستخدمين في النظام
enum UserRole {
  /// مدير عام - صلاحيات كاملة
  owner,

  /// محاسب - إدارة المصروفات والميزانيات
  accountant,

  /// موظف - إضافة مصروفات تحتاج موافقة
  employee,

  /// مراجع - عرض التقارير فقط
  auditor,
}

/// امتداد لـ UserRole لتوفير النصوص والأوصاف
extension UserRoleExtension on UserRole {
  /// الاسم المعروض باللغة الإنجليزية
  String get englishName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.accountant:
        return 'Accountant';
      case UserRole.employee:
        return 'Employee';
      case UserRole.auditor:
        return 'Auditor';
    }
  }

  /// الاسم المعروض باللغة العربية
  String get arabicName {
    switch (this) {
      case UserRole.owner:
        return 'مدير عام';
      case UserRole.accountant:
        return 'محاسب';
      case UserRole.employee:
        return 'موظف';
      case UserRole.auditor:
        return 'مراجع';
    }
  }

  /// الحصول على الاسم المعروض حسب اللغة
  String getDisplayName(bool isRTL) {
    return isRTL ? arabicName : englishName;
  }

  /// الحصول على الاسم المعروض حسب اللغة (اسم مختصر)
  String displayName(bool isRTL) {
    return getDisplayName(isRTL);
  }

  /// الوصف باللغة الإنجليزية
  String get englishDescription {
    switch (this) {
      case UserRole.owner:
        return 'Full access to all features and settings';
      case UserRole.accountant:
        return 'Manage expenses, budgets, and financial reports';
      case UserRole.employee:
        return 'Add expenses that require approval';
      case UserRole.auditor:
        return 'View reports and analytics only';
    }
  }

  /// الوصف باللغة العربية
  String get arabicDescription {
    switch (this) {
      case UserRole.owner:
        return 'صلاحيات كاملة على جميع الميزات والإعدادات';
      case UserRole.accountant:
        return 'إدارة المصروفات والميزانيات والتقارير المالية';
      case UserRole.employee:
        return 'إضافة مصروفات تحتاج موافقة';
      case UserRole.auditor:
        return 'عرض التقارير والإحصائيات فقط';
    }
  }

  /// الحصول على الوصف حسب اللغة
  String getDescription(bool isRTL) {
    return isRTL ? arabicDescription : englishDescription;
  }

  /// الأيقونة المناسبة لكل دور
  String get iconName {
    switch (this) {
      case UserRole.owner:
        return 'admin_panel_settings';
      case UserRole.accountant:
        return 'account_balance';
      case UserRole.employee:
        return 'person';
      case UserRole.auditor:
        return 'visibility';
    }
  }

  /// الأيقونة كـ IconData
  IconData get icon {
    switch (this) {
      case UserRole.owner:
        return Icons.admin_panel_settings;
      case UserRole.accountant:
        return Icons.account_balance;
      case UserRole.employee:
        return Icons.person;
      case UserRole.auditor:
        return Icons.visibility;
    }
  }

  /// اللون المناسب لكل دور

  int get colorValue {
    switch (this) {
      case UserRole.owner:
        return 0xFF6A1B9A; // Owner - Purple dark
      case UserRole.accountant:
        return 0xFF00695C; // Accountant - Teal dark (greenish)
      case UserRole.employee:
        return 0xFF33691E; // Employee - Dark Olive Green
      case UserRole.auditor:
        return 0xFFB71C1C; // Auditor - Dark Red
    }
  }




  /// اللون كـ Color
  Color get color {
    return Color(colorValue);
  }

  /// مستوى الصلاحيات (كلما قل الرقم كلما زادت الصلاحيات)
  int get permissionLevel {
    switch (this) {
      case UserRole.owner:
        return 1;
      case UserRole.accountant:
        return 2;
      case UserRole.employee:
        return 3;
      case UserRole.auditor:
        return 4;
    }
  }
}

/// نموذج المستخدم
class User extends HiveObject {
  String id;
  String name;
  String email;
  String? phone;
  UserRole role;
  String? department;
  String? employeeId;
  bool isActive;
  DateTime createdAt;
  DateTime? lastLoginAt;
  String? profileImagePath;
  String? password; // كلمة المرور (اختيارية للتوافق مع البيانات القديمة)

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.department,
    this.employeeId,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImagePath,
    this.password,
  });

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'employeeId': employeeId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'profileImagePath': profileImagePath,
      'password': password,
    };
  }

  /// إنشاء من JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => UserRole.employee,
      ),
      department: json['department'],
      employeeId: json['employeeId'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'])
              : null,
      profileImagePath: json['profileImagePath'],
      password: json['password'],
    );
  }

  /// نسخة محدثة من المستخدم
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    String? employeeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImagePath,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      password: password ?? this.password,
    );
  }

  /// التحقق من أن المستخدم له صلاحية معينة
  bool hasPermission(UserRole requiredRole) {
    return role.permissionLevel <= requiredRole.permissionLevel;
  }

  /// التحقق من أن المستخدم مدير
  bool get isOwner => role == UserRole.owner;

  /// التحقق من أن المستخدم محاسب
  bool get isAccountant => role == UserRole.accountant;

  /// التحقق من أن المستخدم موظف
  bool get isEmployee => role == UserRole.employee;

  /// التحقق من أن المستخدم مراجع
  bool get isAuditor => role == UserRole.auditor;

  /// التحقق من أن المستخدم يمكنه إدارة المستخدمين
  bool get canManageUsers => hasPermission(UserRole.owner);

  /// التحقق من أن المستخدم يمكنه إدارة المصروفات
  bool get canManageExpenses => hasPermission(UserRole.accountant);

  /// التحقق من أن المستخدم يمكنه إضافة مصروفات
  bool get canAddExpenses => hasPermission(UserRole.employee);

  /// التحقق من أن المستخدم يمكنه عرض التقارير
  bool get canViewReports => hasPermission(UserRole.auditor);

  /// التحقق من أن المستخدم يمكنه الموافقة على المصروفات
  bool get canApproveExpenses => hasPermission(UserRole.accountant);

  /// الحصول على اسم المستخدم المعروض
  String getDisplayName() {
    return name.isNotEmpty ? name : email;
  }

  /// الحصول على معلومات المستخدم للعرض
  String getUserInfo(bool isRTL) {
    final roleName = role.getDisplayName(isRTL);
    final departmentInfo = department != null ? ' - $department' : '';
    return '$roleName$departmentInfo';
  }
}

/// Hive Adapter للمستخدم
class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final name = reader.readString();
      final email = reader.readString();
      final hasPhone = reader.readBool();
      final phone = hasPhone ? reader.readString() : null;
      final roleString = reader.readString();
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.employee,
      );
      final hasDepartment = reader.readBool();
      final department = hasDepartment ? reader.readString() : null;
      final hasEmployeeId = reader.readBool();
      final employeeId = hasEmployeeId ? reader.readString() : null;
      final isActive = reader.readBool();
      final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final hasLastLogin = reader.readBool();
      final lastLoginAt =
          hasLastLogin
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null;
      final hasProfileImage = reader.readBool();
      final profileImagePath = hasProfileImage ? reader.readString() : null;

      // قراءة كلمة المرور (اختيارية للتوافق مع البيانات القديمة)
      String? password;
      try {
        final hasPassword = reader.readBool();
        password = hasPassword ? reader.readString() : null;
      } catch (e) {
        password = null; // للبيانات القديمة التي لا تحتوي على كلمة مرور
      }

      return User(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        department: department,
        employeeId: employeeId,
        isActive: isActive,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
        profileImagePath: profileImagePath,
        password: password,
      );
    } catch (e) {
      // في حالة الخطأ، أعد مستخدم افتراضي
      return User(
        id: 'error_user',
        name: 'خطأ في البيانات',
        email: 'error@example.com',
        role: UserRole.employee,
        createdAt: DateTime.now(),
        password: null,
      );
    }
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeBool(obj.phone != null);
    if (obj.phone != null) {
      writer.writeString(obj.phone!);
    }
    writer.writeString(obj.role.name);
    writer.writeBool(obj.department != null);
    if (obj.department != null) {
      writer.writeString(obj.department!);
    }
    writer.writeBool(obj.employeeId != null);
    if (obj.employeeId != null) {
      writer.writeString(obj.employeeId!);
    }
    writer.writeBool(obj.isActive);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.lastLoginAt != null);
    if (obj.lastLoginAt != null) {
      writer.writeInt(obj.lastLoginAt!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.profileImagePath != null);
    if (obj.profileImagePath != null) {
      writer.writeString(obj.profileImagePath!);
    }
    writer.writeBool(obj.password != null);
    if (obj.password != null) {
      writer.writeString(obj.password!);
    }
  }
}
