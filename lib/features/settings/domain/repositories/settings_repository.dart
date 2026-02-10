import 'package:expense_tracker/features/settings/data/models/settings_model.dart';

/// Abstract repository interface for settings operations.
///
/// Defines the contract for user settings data access.
/// Implementations handle the actual data fetching (API, local storage, etc.).
abstract class SettingsRepository {
  /// Get the current user's settings.
  ///
  /// Returns a [SettingsModel] with all configuration values.
  Future<SettingsModel> getSettings();

  /// Update user settings.
  ///
  /// Only the provided non-null fields will be updated.
  /// Returns the updated [SettingsModel].
  Future<SettingsModel> updateSettings({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  });

  /// Reset all settings to their default values.
  ///
  /// Returns the reset [SettingsModel] with default values.
  Future<SettingsModel> resetSettings();
}
