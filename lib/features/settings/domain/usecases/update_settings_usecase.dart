import 'package:expense_tracker/features/settings/domain/entities/settings_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class UpdateSettingsUseCase {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  Future<SettingsEntity> call({
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
