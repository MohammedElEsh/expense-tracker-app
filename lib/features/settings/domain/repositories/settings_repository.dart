import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<SettingsEntity> updateSettings({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  });
  Future<SettingsEntity> resetSettings();
  Future<void> setAppMode(AppMode mode);
}
