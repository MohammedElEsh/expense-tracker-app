// Home Feature - Domain Layer - Use Case
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';

class LogoutUseCase {
  Future<void> call() async {
    // 1. تسجيل الخروج عبر REST API
    await serviceLocator.authRepository.logout();

    // 2. مسح البيانات المحلية
    await SettingsService.clearModeAndCompany();
  }
}
