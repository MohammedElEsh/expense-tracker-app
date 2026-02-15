import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';

class SetAppModeUseCase {
  final SettingsRepository repository;

  SetAppModeUseCase(this.repository);

  Future<void> call(AppMode mode) => repository.setAppMode(mode);
}
