import 'package:expense_tracker/features/settings/data/models/settings_model.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

/// Use case for retrieving the current user's settings.
///
/// Fetches settings including currency, language, theme, and notification
/// preferences from the repository.
class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Returns a [SettingsModel] containing all user settings.
  Future<SettingsModel> call() {
    return repository.getSettings();
  }
}
