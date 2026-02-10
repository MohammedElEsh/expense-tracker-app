// ✅ Clean Architecture - Local DataSource
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:expense_tracker/features/users/data/models/user.dart';

class UserService {
  static const String _usersBoxName = 'users';

  /// تهيئة خدمة المستخدمين
  static Future<void> init() async {
    // لا نحتاج لاستدعاء DatabaseService.init() هنا
    // لأنه يتم استدعاؤه في main_dev.dart
  }

  /// تشفير كلمة المرور
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// التحقق من كلمة المرور
  static bool _verifyPassword(String password, String hashedPassword) {
    return _hashPassword(password) == hashedPassword;
  }

  /// إضافة مستخدم جديد
  static Future<User> createUser({
    required String name,
    required String email,
    required UserRole role,
    String? phone,
    String? department,
    String? employeeId,
    required String password, // كلمة المرور أصبحت إجبارية
  }) async {
    final box = await Hive.openBox(_usersBoxName);

    // التحقق من عدم وجود مستخدم بنفس البريد الإلكتروني
    final existingUsers = box.values.cast<User>();
    if (existingUsers.any((user) => user.email == email)) {
      throw Exception('المستخدم موجود بالفعل بهذا البريد الإلكتروني');
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      department: department,
      employeeId: employeeId,
      isActive: true,
      createdAt: DateTime.now(),
      password: _hashPassword(password), // كلمة المرور إجبارية
    );

    await box.put(user.id, user);
    return user;
  }

  /// تحديث مستخدم
  static Future<User> updateUser(User user) async {
    final box = await Hive.openBox(_usersBoxName);
    await box.put(user.id, user);
    return user;
  }

  /// تحديث كلمة مرور المستخدم
  static Future<User> updateUserPassword(
    String userId,
    String newPassword,
  ) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('المستخدم غير موجود');
    }

    final updatedUser = user.copyWith(password: _hashPassword(newPassword));

    return await updateUser(updatedUser);
  }

  /// حذف مستخدم
  static Future<void> deleteUser(String userId) async {
    final box = await Hive.openBox(_usersBoxName);
    await box.delete(userId);
  }

  /// الحصول على جميع المستخدمين
  static Future<List<User>> getAllUsers() async {
    final box = await Hive.openBox(_usersBoxName);
    return box.values.cast<User>().toList();
  }

  /// الحصول على مستخدم بالمعرف
  static Future<User?> getUserById(String userId) async {
    final box = await Hive.openBox(_usersBoxName);
    return box.get(userId);
  }

  /// الحصول على مستخدم بالبريد الإلكتروني
  static Future<User?> getUserByEmail(String email) async {
    final users = await getAllUsers();
    try {
      return users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  static Future<User?> loginWithPassword(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null || !user.isActive) {
      return null;
    }

    // إذا لم يكن للمستخدم كلمة مرور، لا يمكنه تسجيل الدخول
    if (user.password == null) {
      return null;
    }

    // التحقق من كلمة المرور
    if (!_verifyPassword(password, user.password!)) {
      return null;
    }

    // تحديث وقت آخر تسجيل دخول
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    await updateUser(updatedUser);

    return updatedUser;
  }

  /// تسجيل الدخول بدون كلمة مرور (للمستخدمين القدامى فقط)
  static Future<User?> loginWithoutPassword(String email) async {
    final user = await getUserByEmail(email);
    if (user == null || !user.isActive) {
      return null;
    }

    // جميع المستخدمين الجدد يجب أن يكون لديهم كلمة مرور
    // فقط المستخدمين القدامى الذين لا يملكون كلمة مرور يمكنهم الدخول بدونها
    if (user.password != null) {
      return null; // المستخدم لديه كلمة مرور، يجب استخدامها
    }

    // تحديث وقت آخر تسجيل دخول
    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    await updateUser(updatedUser);

    return updatedUser;
  }

  /// إنشاء مستخدم افتراضي (مدير عام)
  static Future<User> createDefaultAdmin() async {
    try {
      // التحقق من وجود مدير بالفعل
      final existingUsers = await getAllUsers();
      final adminExists = existingUsers.any(
        (user) => user.role == UserRole.owner,
      );

      if (adminExists) {
        return existingUsers.firstWhere((user) => user.role == UserRole.owner);
      }

      // إنشاء مدير افتراضي
      return await createUser(
        name: 'مدير عام',
        email: 'admin@expense-tracker.com',
        role: UserRole.owner,
        password: 'admin123', // كلمة مرور افتراضية
      );
    } catch (e) {
      throw Exception('فشل في إنشاء المدير الافتراضي: $e');
    }
  }

  /// التحقق من وجود مستخدمين
  static Future<bool> hasUsers() async {
    final users = await getAllUsers();
    return users.isNotEmpty;
  }

  /// الحصول على المستخدمين النشطين فقط
  static Future<List<User>> getActiveUsers() async {
    final users = await getAllUsers();
    return users.where((user) => user.isActive).toList();
  }

  /// تفعيل/إلغاء تفعيل مستخدم
  static Future<User> toggleUserStatus(String userId) async {
    final user = await getUserById(userId);
    if (user == null) {
      throw Exception('المستخدم غير موجود');
    }

    final updatedUser = user.copyWith(isActive: !user.isActive);

    return await updateUser(updatedUser);
  }
}
