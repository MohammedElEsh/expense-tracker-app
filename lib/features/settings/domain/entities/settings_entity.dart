import 'package:expense_tracker/core/domain/app_mode.dart';

class SettingsEntity {
  final String currency;
  final String currencySymbol;
  final List<String> availableCurrencies;
  final Map<String, String> codeToSymbol;
  final bool isDarkMode;
  final String language;
  final AppMode appMode;
  final String? companyName;
  final String? companyLogo;
  final bool notifications;

  const SettingsEntity({
    required this.currency,
    required this.currencySymbol,
    required this.availableCurrencies,
    required this.codeToSymbol,
    required this.isDarkMode,
    required this.language,
    required this.appMode,
    this.companyName,
    this.companyLogo,
    this.notifications = false,
  });
}
