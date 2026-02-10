import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final bool forceReload;
  const LoadSettings({this.forceReload = false});

  @override
  List<Object?> get props => [forceReload];
}

class ChangeCurrency extends SettingsEvent {
  final String currency;
  const ChangeCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class ChangeLanguage extends SettingsEvent {
  final String language;
  const ChangeLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class ToggleDarkMode extends SettingsEvent {
  final bool isDarkMode;
  const ToggleDarkMode(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class SetAppMode extends SettingsEvent {
  final AppMode appMode;
  const SetAppMode(this.appMode);

  @override
  List<Object?> get props => [appMode];
}

// Backwards compatibility with legacy code
class ChangeAppMode extends SettingsEvent {
  final AppMode appMode;
  const ChangeAppMode(this.appMode);

  @override
  List<Object?> get props => [appMode];
}

class UpdateSettings extends SettingsEvent {
  final String? currency;
  final String? language;
  final String? theme;
  final bool? notifications;
  final String? companyName;
  final String? companyLogo;

  const UpdateSettings({
    this.currency,
    this.language,
    this.theme,
    this.notifications,
    this.companyName,
    this.companyLogo,
  });

  @override
  List<Object?> get props => [
    currency,
    language,
    theme,
    notifications,
    companyName,
    companyLogo,
  ];
}

class ResetSettings extends SettingsEvent {
  const ResetSettings();
}