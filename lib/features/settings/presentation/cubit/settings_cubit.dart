import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/set_app_mode_usecase.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
    required ResetSettingsUseCase resetSettingsUseCase,
    required SetAppModeUseCase setAppModeUseCase,
  })  : _getSettings = getSettingsUseCase,
        _updateSettings = updateSettingsUseCase,
        _resetSettings = resetSettingsUseCase,
        _setAppMode = setAppModeUseCase,
        super(const SettingsState());

  final GetSettingsUseCase _getSettings;
  final UpdateSettingsUseCase _updateSettings;
  final ResetSettingsUseCase _resetSettings;
  final SetAppModeUseCase _setAppMode;

  Future<void> loadSettings({bool forceReload = false}) async {
    if (!forceReload && (state.isLoading || state.hasLoaded)) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entity = await _getSettings();
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        isLoading: false,
        hasLoaded: true,
        clearError: true,
      ));
    } catch (e) {
      debugPrint('SettingsCubit loadSettings error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: ${e.toString()}',
      ));
    }
  }

  Future<void> changeCurrency(String currency) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entity = await _updateSettings(currency: currency);
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        isLoading: false,
        clearError: true,
      ));
    } on NetworkException catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Network error: Currency saved locally but not synced to server',
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Server error: ${e.message}'));
    } catch (_) {
      debugPrint('SettingsCubit changeCurrency error');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update currency',
      ));
    }
  }

  Future<void> changeLanguage(String language) async {
    try {
      final entity = await _updateSettings(language: language);
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        clearError: true,
      ));
    } on NetworkException {
      emit(state.copyWith(
        error: 'Network error: Settings saved locally but not synced to server',
      ));
    } catch (e) {
      debugPrint('SettingsCubit changeLanguage error: $e');
      emit(state.copyWith(error: 'Failed to update language: ${e.toString()}'));
    }
  }

  Future<void> toggleDarkMode(bool isDarkMode) async {
    try {
      final entity = await _updateSettings(
        theme: isDarkMode ? 'dark' : 'light',
      );
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        clearError: true,
      ));
    } on NetworkException {
      emit(state.copyWith(
        error: 'Network error: Settings saved locally but not synced to server',
      ));
    } catch (e) {
      debugPrint('SettingsCubit toggleDarkMode error: $e');
      emit(state.copyWith(error: 'Failed to update theme: ${e.toString()}'));
    }
  }

  Future<void> setAppMode(AppMode appMode) async {
    try {
      await _setAppMode(appMode);
      emit(state.copyWith(appMode: appMode, clearError: true));
    } catch (e) {
      debugPrint('SettingsCubit setAppMode error: $e');
      emit(state.copyWith(error: 'Failed to update app mode: ${e.toString()}'));
    }
  }

  Future<void> changeAppMode(AppMode appMode) async => setAppMode(appMode);

  Future<void> updateSettings({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entity = await _updateSettings(
        currency: currency,
        language: language,
        theme: theme,
        notifications: notifications,
        companyName: companyName,
        companyLogo: companyLogo,
      );
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        isLoading: false,
        clearError: true,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Network error: ${e.message}'));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Server error: ${e.message}'));
    } catch (e) {
      debugPrint('SettingsCubit updateSettings error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to update settings: ${e.toString()}',
      ));
    }
  }

  Future<void> resetSettings() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entity = await _resetSettings();
      emit(state.copyWith(
        currency: entity.currency,
        currencySymbol: entity.currencySymbol,
        availableCurrencies: entity.availableCurrencies,
        codeToSymbol: entity.codeToSymbol,
        isDarkMode: entity.isDarkMode,
        language: entity.language,
        appMode: entity.appMode,
        companyName: entity.companyName,
        companyLogo: entity.companyLogo,
        notifications: entity.notifications,
        isLoading: false,
        clearError: true,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Network error: ${e.message}'));
    } on ServerException catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Server error: ${e.message}'));
    } catch (e) {
      debugPrint('SettingsCubit resetSettings error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to reset settings: ${e.toString()}',
      ));
    }
  }
}
