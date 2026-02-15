import 'package:expense_tracker/features/settings/domain/entities/settings_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<SettingsEntity> call() => repository.getSettings();
}
