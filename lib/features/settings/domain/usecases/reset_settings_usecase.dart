import 'package:expense_tracker/features/settings/domain/entities/settings_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class ResetSettingsUseCase {
  final SettingsRepository repository;

  ResetSettingsUseCase(this.repository);

  Future<SettingsEntity> call() => repository.resetSettings();
}
