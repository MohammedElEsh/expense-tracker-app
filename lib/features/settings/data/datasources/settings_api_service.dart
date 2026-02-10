import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/settings/data/models/settings_model.dart';

/// Settings API Service - Remote data source for settings
/// Handles all API calls related to user settings
class SettingsApiService {
  final ApiService _apiService;

  SettingsApiService({required ApiService apiService})
    : _apiService = apiService;

  /// GET /api/settings
  /// Fetch current user settings from API
  Future<SettingsModel> getSettings() async {
    try {
      debugPrint('🔍 GET /api/settings - Fetching settings...');

      final response = await _apiService.get('/api/settings');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both direct settings object and wrapped response
        Map<String, dynamic> settingsMap;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('settings')) {
            settingsMap = data['settings'] as Map<String, dynamic>;
          } else {
            settingsMap = data;
          }
        } else {
          throw ServerException('Invalid response format from settings API');
        }

        final settings = SettingsModel.fromMap(settingsMap);
        debugPrint(
          '✅ Settings loaded: ${settings.currency}, ${settings.language}, ${settings.theme}',
        );
        return settings;
      }

      throw ServerException(
        'Failed to load settings',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading settings: $e');
    }
  }

  /// PUT /api/settings
  /// Update user settings
  Future<SettingsModel> updateSettings({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  }) async {
    try {
      debugPrint('📤 PUT /api/settings - Updating settings...');

      final body = <String, dynamic>{};

      if (currency != null) body['currency'] = currency;
      if (language != null) body['language'] = language;
      if (theme != null) body['theme'] = theme;
      if (notifications != null) body['notifications'] = notifications;
      if (companyName != null) body['companyName'] = companyName;
      if (companyLogo != null) body['companyLogo'] = companyLogo;

      debugPrint('📦 Request body: $body');

      final response = await _apiService.put('/api/settings', data: body);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both direct settings object and wrapped response
        Map<String, dynamic> settingsMap;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('settings')) {
            settingsMap = data['settings'] as Map<String, dynamic>;
          } else {
            settingsMap = data;
          }
        } else {
          throw ServerException('Invalid response format from settings API');
        }

        final settings = SettingsModel.fromMap(settingsMap);
        debugPrint('✅ Settings updated successfully');
        return settings;
      }

      throw ServerException(
        'Failed to update settings',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating settings: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error updating settings: $e');
    }
  }

  /// POST /api/settings/reset
  /// Reset settings to default values
  Future<SettingsModel> resetSettings() async {
    try {
      debugPrint('🔄 POST /api/settings/reset - Resetting settings...');

      final response = await _apiService.post('/api/settings/reset');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Handle both direct settings object and wrapped response
        Map<String, dynamic> settingsMap;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('settings')) {
            settingsMap = data['settings'] as Map<String, dynamic>;
          } else {
            settingsMap = data;
          }
        } else {
          throw ServerException('Invalid response format from settings API');
        }

        final settings = SettingsModel.fromMap(settingsMap);
        debugPrint('✅ Settings reset to defaults');
        return settings;
      }

      throw ServerException(
        'Failed to reset settings',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error resetting settings: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error resetting settings: $e');
    }
  }
}
