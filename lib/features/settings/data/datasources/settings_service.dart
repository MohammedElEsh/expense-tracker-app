import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';

class SettingsService {
  static const String _currencyKey = 'currency';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _appModeKey = 'app_mode';
  static const String _companyIdKey = 'company_id';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Currency settings
  static String get currency => _prefs.getString(_currencyKey) ?? 'SAR';
  static Future<void> setCurrency(String currency) async {
    await _prefs.setString(_currencyKey, currency);
  }

  // Dark mode settings
  static bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;
  static Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_darkModeKey, isDark);
  }

  // Language settings
  static String get language => _prefs.getString(_languageKey) ?? 'en';
  static Future<void> setLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  // App mode settings
  static AppMode get appMode {
    final modeString = _prefs.getString(_appModeKey) ?? 'personal';
    final mode = AppMode.values.firstWhere(
      (mode) => mode.name == modeString,
      orElse: () => AppMode.personal,
    );
    debugPrint('⚙️ SettingsService.appMode: ${mode.name}');
    return mode;
  }

  static Future<void> setAppMode(AppMode appMode) async {
    debugPrint('⚙️ تعيين الوضع: ${appMode.name}');
    await _prefs.setString(_appModeKey, appMode.name);
  }

  // التحقق من وجود اختيار الوضع
  static bool get hasSelectedMode => _prefs.containsKey(_appModeKey);

  // Company ID settings (for business mode)
  static String? get companyId {
    final id = _prefs.getString(_companyIdKey);
    debugPrint('⚙️ SettingsService.companyId: $id');
    return id;
  }

  static Future<void> setCompanyId(String? companyId) async {
    debugPrint('⚙️ تعيين معرف الشركة: $companyId');
    if (companyId != null) {
      await _prefs.setString(_companyIdKey, companyId);
    } else {
      await _prefs.remove(_companyIdKey);
    }
  }

  // Clear mode and company on logout
  static Future<void> clearModeAndCompany() async {
    debugPrint('⚙️ مسح وضع التطبيق ومعرف الشركة عند تسجيل الخروج');
    await _prefs.remove(_appModeKey);
    await _prefs.remove(_companyIdKey);
  }

  // Currency symbols
  static String getCurrencySymbol(String currency) {
    switch (currency) {
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
        return currency;
    }
  }

  static List<String> get availableCurrencies => [
    'SAR',
    'EGP',
    'USD',
    'GBP',
    'EUR',
    'JPY',
    'AED',
  ];

  /// Convert currency symbol or code to API-valid code
  /// Handles both codes (SAR) and symbols (ر.س)
  static String getCurrencyCode(String currencyInput) {
    // If already a valid code, return as-is
    if (availableCurrencies.contains(currencyInput)) {
      return currencyInput;
    }

    // Convert symbol to code
    switch (currencyInput) {
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
        // Default to SAR if unknown
        return 'SAR';
    }
  }
}
