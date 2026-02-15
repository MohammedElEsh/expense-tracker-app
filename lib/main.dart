import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/users/data/datasources/user_service.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.blue),
  );

  await initInjector();
  debugPrint('✅ GetIt injector initialized');

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());

  try {
    await _cleanupOldLocalData();
  } catch (e) {
    debugPrint('تنبيه: خطأ في تنظيف البيانات القديمة: $e');
  }

  await UserService.init();

  try {
    await _createDefaultUser();
  } catch (e) {
    debugPrint('خطأ في إنشاء المستخدم الافتراضي: $e');
  }

  runApp(const ExpenseTrackerApp());
}

/// تنظيف البيانات القديمة من Local Storage
/// (المشاريع والموردين انتقلوا إلى Firebase)
Future<void> _cleanupOldLocalData() async {
  try {
    // حذف Projects Box القديم
    if (await Hive.boxExists('projects')) {
      await Hive.deleteBoxFromDisk('projects');
      debugPrint('✅ تم حذف بيانات المشاريع القديمة من Local Storage');
    }

    // حذف Vendors Box القديم
    if (await Hive.boxExists('vendors')) {
      await Hive.deleteBoxFromDisk('vendors');
      debugPrint('✅ تم حذف بيانات الموردين القديمة من Local Storage');
    }
  } catch (e) {
    debugPrint('⚠️ خطأ في حذف البيانات القديمة: $e');
  }
}

Future<void> _createDefaultUser() async {
  try {
    final hasUsers = await UserService.hasUsers();
    if (!hasUsers) {
      await UserService.createDefaultAdmin();
      debugPrint('تم إنشاء مدير افتراضي');
    }
  } catch (e) {
    debugPrint('خطأ في إنشاء المستخدم الافتراضي: $e');
  }
}
