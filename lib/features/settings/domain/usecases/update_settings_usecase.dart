import 'package:expense_tracker/features/settings/data/models/settings_model.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

/// Use case for updating user settings.
///
/// Allows partial updates -- only the provided non-null fields are changed.
class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Pass only the settings fields you want to change.
  /// Returns the fully updated [SettingsModel].
  Future<SettingsModel> call({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  }) {
    return repository.updateSettings(
      currency: currency,
      language: language,
      theme: theme,
      notifications: notifications,
      companyName: companyName,
      companyLogo: companyLogo,
    );
  }
}
