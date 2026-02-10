import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

/// Centralized SharedPreferences helper for the entire application
/// Provides type-safe methods for storing and retrieving data
class PrefHelper {
  // Keys for stored data
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _userDataKey = 'auth_user_data';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _recurringExpenseRemindersKey =
      'recurring_expense_reminders_enabled';

  SharedPreferences? _prefs;

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _sharedPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==========================================================================
  // AUTH TOKEN MANAGEMENT
  // ==========================================================================

  /// Get stored JWT token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_authTokenKey);
    } catch (e) {
      debugPrint('❌ Error reading token: $e');
      throw CacheException('Failed to read auth token');
    }
  }

  /// Store JWT token
  Future<void> saveAuthToken(String token) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_authTokenKey, token);
      debugPrint('✅ Token saved');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
      throw CacheException('Failed to save auth token');
    }
  }

  /// Clear stored token
  Future<void> clearAuthToken() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove(_authTokenKey);
      debugPrint('✅ Token cleared');
    } catch (e) {
      debugPrint('❌ Error clearing token: $e');
      throw CacheException('Failed to clear auth token');
    }
  }

  /// Check if user has valid token
  Future<bool> hasAuthToken() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ==========================================================================
  // USER DATA MANAGEMENT
  // ==========================================================================

  /// Get stored user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('❌ Error reading user ID: $e');
      return null;
    }
  }

  /// Store user ID
  Future<void> saveUserId(String userId) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_userIdKey, userId);
      debugPrint('✅ User ID saved');
    } catch (e) {
      debugPrint('❌ Error saving user ID: $e');
      throw CacheException('Failed to save user ID');
    }
  }

  /// Get stored user data (JSON string)
  Future<String?> getUserData() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_userDataKey);
    } catch (e) {
      debugPrint('❌ Error reading user data: $e');
      return null;
    }
  }

  /// Store user data (JSON string)
  Future<void> saveUserData(String userData) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_userDataKey, userData);
      debugPrint('✅ User data saved');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
      throw CacheException('Failed to save user data');
    }
  }

  /// Clear all user-related data
  Future<void> clearUserData() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove(_userIdKey);
      await prefs.remove(_userDataKey);
      debugPrint('✅ User data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
      throw CacheException('Failed to clear user data');
    }
  }

  /// Clear all auth-related data (token + user data)
  Future<void> clearAuthData() async {
    await clearAuthToken();
    await clearUserData();
  }

  // ==========================================================================
  // APP SETTINGS
  // ==========================================================================

  /// Get theme mode (light/dark/system)
  Future<String?> getThemeMode() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_themeKey);
    } catch (e) {
      debugPrint('❌ Error reading theme mode: $e');
      return null;
    }
  }

  /// Save theme mode
  Future<void> saveThemeMode(String themeMode) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_themeKey, themeMode);
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
      throw CacheException('Failed to save theme mode');
    }
  }

  /// Get language code
  Future<String?> getLanguageCode() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(_languageKey);
    } catch (e) {
      debugPrint('❌ Error reading language code: $e');
      return null;
    }
  }

  /// Save language code
  Future<void> saveLanguageCode(String languageCode) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('❌ Error saving language code: $e');
      throw CacheException('Failed to save language code');
    }
  }

  /// Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error reading onboarding status: $e');
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setBool(_onboardingKey, completed);
    } catch (e) {
      debugPrint('❌ Error saving onboarding status: $e');
      throw CacheException('Failed to save onboarding status');
    }
  }

  /// Recurring expense reminder notifications (local-only; default true).
  Future<bool> getRecurringExpenseRemindersEnabled() async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getBool(_recurringExpenseRemindersKey) ?? true;
    } catch (e) {
      debugPrint('❌ Error reading recurring reminders: $e');
      return true;
    }
  }

  /// Save recurring expense reminder notifications setting.
  Future<void> setRecurringExpenseRemindersEnabled(bool enabled) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setBool(_recurringExpenseRemindersKey, enabled);
    } catch (e) {
      debugPrint('❌ Error saving recurring reminders: $e');
      throw CacheException('Failed to save recurring reminders setting');
    }
  }

  // ==========================================================================
  // GENERIC METHODS
  // ==========================================================================

  /// Save string value
  Future<void> setString(String key, String value) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('❌ Error saving string: $e');
      throw CacheException('Failed to save string value');
    }
  }

  /// Get string value
  Future<String?> getString(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getString(key);
    } catch (e) {
      debugPrint('❌ Error reading string: $e');
      return null;
    }
  }

  /// Save boolean value
  Future<void> setBool(String key, bool value) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('❌ Error saving bool: $e');
      throw CacheException('Failed to save boolean value');
    }
  }

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getBool(key);
    } catch (e) {
      debugPrint('❌ Error reading bool: $e');
      return null;
    }
  }

  /// Save integer value
  Future<void> setInt(String key, int value) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setInt(key, value);
    } catch (e) {
      debugPrint('❌ Error saving int: $e');
      throw CacheException('Failed to save integer value');
    }
  }

  /// Get integer value
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getInt(key);
    } catch (e) {
      debugPrint('❌ Error reading int: $e');
      return null;
    }
  }

  /// Save double value
  Future<void> setDouble(String key, double value) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.setDouble(key, value);
    } catch (e) {
      debugPrint('❌ Error saving double: $e');
      throw CacheException('Failed to save double value');
    }
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.getDouble(key);
    } catch (e) {
      debugPrint('❌ Error reading double: $e');
      return null;
    }
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.remove(key);
    } catch (e) {
      debugPrint('❌ Error removing key: $e');
      throw CacheException('Failed to remove key');
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      final prefs = await _sharedPrefs;
      await prefs.clear();
      debugPrint('✅ All preferences cleared');
    } catch (e) {
      debugPrint('❌ Error clearing all preferences: $e');
      throw CacheException('Failed to clear all preferences');
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _sharedPrefs;
      return prefs.containsKey(key);
    } catch (e) {
      debugPrint('❌ Error checking key: $e');
      return false;
    }
  }
}
