import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/settings/domain/entities/settings_entity.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_api_service.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    required AppContext appContext,
    SettingsApiService? apiService,
  })  : _appContext = appContext,
        _apiService = apiService;

  final AppContext _appContext;
  final SettingsApiService? _apiService;

  Map<String, String> _codeToSymbol() {
    return {
      for (final c in _appContext.availableCurrencies)
        c: _appContext.getCurrencySymbol(c),
    };
  }

  SettingsEntity _entityFromContext() {
    final currency = _appContext.currency;
    return SettingsEntity(
      currency: currency,
      currencySymbol: _appContext.getCurrencySymbol(currency),
      availableCurrencies: _appContext.availableCurrencies,
      codeToSymbol: _codeToSymbol(),
      isDarkMode: _appContext.isDarkMode,
      language: _appContext.language,
      appMode: _appContext.appMode,
      companyName: null,
      companyLogo: null,
      notifications: false,
    );
  }

  @override
  Future<SettingsEntity> getSettings() async {
    if (_apiService != null) {
      try {
        final model = await _apiService.getSettings();
        await _appContext.setCurrency(model.currency);
        await _appContext.setLanguage(model.language);
        await _appContext.setDarkMode(model.isDarkMode);
        return SettingsEntity(
          currency: model.currency,
          currencySymbol: _appContext.getCurrencySymbol(model.currency),
          availableCurrencies: _appContext.availableCurrencies,
          codeToSymbol: _codeToSymbol(),
          isDarkMode: model.isDarkMode,
          language: model.language,
          appMode: _appContext.appMode,
          companyName: model.companyName,
          companyLogo: model.companyLogo,
          notifications: model.notifications,
        );
      } on NetworkException catch (e) {
        debugPrint('SettingsRepository: network error, using local: $e');
      } on ServerException catch (e) {
        debugPrint('SettingsRepository: server error, using local: $e');
      }
    }
    return _entityFromContext();
  }

  @override
  Future<SettingsEntity> updateSettings({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  }) async {
    if (currency != null) {
      final code = _appContext.getCurrencyCode(currency);
      await _appContext.setCurrency(code);
    }
    if (language != null) await _appContext.setLanguage(language);
    if (theme != null) await _appContext.setDarkMode(theme == 'dark');

    if (_apiService != null) {
      try {
        final code = currency != null ? _appContext.getCurrencyCode(currency) : null;
        final model = await _apiService.updateSettings(
          currency: code ?? currency,
          language: language,
          theme: theme,
          notifications: notifications,
          companyName: companyName,
          companyLogo: companyLogo,
        );
        await _appContext.setCurrency(model.currency);
        await _appContext.setLanguage(model.language);
        await _appContext.setDarkMode(model.isDarkMode);
        return SettingsEntity(
          currency: model.currency,
          currencySymbol: _appContext.getCurrencySymbol(model.currency),
          availableCurrencies: _appContext.availableCurrencies,
          codeToSymbol: _codeToSymbol(),
          isDarkMode: model.isDarkMode,
          language: model.language,
          appMode: _appContext.appMode,
          companyName: model.companyName,
          companyLogo: model.companyLogo,
          notifications: model.notifications,
        );
      } on NetworkException catch (e) {
        debugPrint('SettingsRepository: update network error: $e');
      } on ServerException catch (e) {
        debugPrint('SettingsRepository: update server error: $e');
      }
    }
    return _entityFromContext();
  }

  @override
  Future<SettingsEntity> resetSettings() async {
    if (_apiService != null) {
      try {
        final model = await _apiService.resetSettings();
        await _appContext.setCurrency(model.currency);
        await _appContext.setLanguage(model.language);
        await _appContext.setDarkMode(model.isDarkMode);
        return SettingsEntity(
          currency: model.currency,
          currencySymbol: _appContext.getCurrencySymbol(model.currency),
          availableCurrencies: _appContext.availableCurrencies,
          codeToSymbol: _codeToSymbol(),
          isDarkMode: model.isDarkMode,
          language: model.language,
          appMode: _appContext.appMode,
          companyName: model.companyName,
          companyLogo: model.companyLogo,
          notifications: model.notifications,
        );
      } on NetworkException catch (e) {
        debugPrint('SettingsRepository: reset network error: $e');
      } on ServerException catch (e) {
        debugPrint('SettingsRepository: reset server error: $e');
      }
    }
    return _entityFromContext();
  }

  @override
  Future<void> setAppMode(AppMode mode) async {
    await _appContext.setAppMode(mode);
  }
}
