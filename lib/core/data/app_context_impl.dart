import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';

class AppContextImpl implements AppContext {
  AppContextImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _currencyKey = 'currency';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _appModeKey = 'app_mode';
  static const String _companyIdKey = 'company_id';

  @override
  AppMode get appMode {
    final s = _prefs.getString(_appModeKey) ?? 'personal';
    return AppMode.values.firstWhere(
      (m) => m.name == s,
      orElse: () => AppMode.personal,
    );
  }

  @override
  String? get companyId => _prefs.getString(_companyIdKey);

  @override
  Future<void> setAppMode(AppMode mode) async {
    await _prefs.setString(_appModeKey, mode.name);
  }

  @override
  Future<void> setCompanyId(String? id) async {
    if (id != null) {
      await _prefs.setString(_companyIdKey, id);
    } else {
      await _prefs.remove(_companyIdKey);
    }
  }

  @override
  Future<void> clearModeAndCompany() async {
    await _prefs.remove(_appModeKey);
    await _prefs.remove(_companyIdKey);
  }

  @override
  String get currency => _prefs.getString(_currencyKey) ?? 'SAR';

  @override
  Future<void> setCurrency(String value) async {
    await _prefs.setString(_currencyKey, value);
  }

  @override
  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  @override
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  @override
  String get language => _prefs.getString(_languageKey) ?? 'en';

  @override
  Future<void> setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
  }

  @override
  bool get hasSelectedMode => _prefs.containsKey(_appModeKey);

  @override
  List<String> get availableCurrencies =>
      ['SAR', 'EGP', 'USD', 'GBP', 'EUR', 'JPY', 'AED'];

  @override
  String getCurrencySymbol(String code) {
    switch (code) {
      case 'SAR':
        return 'ر.س';
      case 'EGP':
        return 'ج.م';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'AED':
        return 'د.إ';
      default:
        return code;
    }
  }

  @override
  String getCurrencyCode(String input) {
    if (availableCurrencies.contains(input)) return input;
    switch (input) {
      case 'ر.س':
        return 'SAR';
      case 'ج.م':
        return 'EGP';
      case '\$':
        return 'USD';
      case '£':
        return 'GBP';
      case '€':
        return 'EUR';
      case '¥':
        return 'JPY';
      case 'د.إ':
        return 'AED';
      default:
        return 'SAR';
    }
  }
}
