import 'package:expense_tracker/core/domain/app_mode.dart';

/// Injectable abstraction for app/settings context.
/// Data sources depend on this instead of static SettingsService.
abstract class AppContext {
  AppMode get appMode;
  String? get companyId;
  Future<void> setAppMode(AppMode mode);
  Future<void> setCompanyId(String? id);
  Future<void> clearModeAndCompany();

  String get currency;
  Future<void> setCurrency(String value);
  bool get isDarkMode;
  Future<void> setDarkMode(bool value);
  String get language;
  Future<void> setLanguage(String value);

  List<String> get availableCurrencies;
  String getCurrencySymbol(String currencyCode);
  String getCurrencyCode(String input);

  bool get hasSelectedMode;
}
