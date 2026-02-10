import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_data_source.dart';

/// Legacy wrapper service for backward compatibility
/// This maintains the static interface used by main_dev.dart and main_prod.dart
class OnboardingService {
  static final OnboardingLocalDataSourceImpl _dataSource =
      OnboardingLocalDataSourceImpl();
  static bool _initialized = false;
  static bool _isCompleted = false;

  static Future<void> init() async {
    if (!_initialized) {
      await _dataSource.init();
      _isCompleted = await _dataSource.isOnboardingCompleted();
      _initialized = true;
    }
  }

  static bool get isOnboardingCompleted {
    // يعيد القيمة المخزنة في الـ cache بعد التهيئة
    return _isCompleted;
  }

  static Future<void> completeOnboarding() async {
    await init();
    await _dataSource.setOnboardingCompleted(true);
    _isCompleted = true; // تحديث الـ cache
  }

  static Future<void> resetOnboarding() async {
    await init();
    await _dataSource.setOnboardingCompleted(false);
    _isCompleted = false; // تحديث الـ cache
  }
}
