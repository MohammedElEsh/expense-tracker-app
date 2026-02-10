import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_api_service.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsApiService? _apiService;

  SettingsBloc({SettingsApiService? apiService})
    : _apiService = apiService,
      super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeCurrency>(_onChangeCurrency);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<SetAppMode>(_onSetAppMode);
    on<ChangeAppMode>(_onChangeAppMode);
    on<UpdateSettings>(_onUpdateSettings);
    on<ResetSettings>(_onResetSettings);
  }

  /// Load settings from API, fallback to local storage if API fails
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    // Guard: Skip if already loading or already loaded (unless forceReload is true)
    if (!event.forceReload && (state.isLoading || state.hasLoaded)) {
      debugPrint('⏭️ Skipping LoadSettings - isLoading: ${state.isLoading}, hasLoaded: ${state.hasLoaded}');
      return;
    }
    
    if (event.forceReload) {
      debugPrint('🔄 Force reloading settings after auth state change');
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Initialize local service first
      await SettingsService.init();

      // Try to load from API if available
      if (_apiService != null) {
        try {
          final settings = await _apiService.getSettings();

          // Update local cache
          await SettingsService.setCurrency(settings.currency);
          await SettingsService.setLanguage(settings.language);
          await SettingsService.setDarkMode(settings.isDarkMode);

          emit(
            state.copyWith(
              currency: settings.currency,
              language: settings.language,
              isDarkMode: settings.isDarkMode,
              companyName: settings.companyName,
              companyLogo: settings.companyLogo,
              notifications: settings.notifications,
              // Read appMode from SettingsService (set from API during login)
              appMode: SettingsService.appMode,
              isLoading: false,
              hasLoaded: true,
              clearError: true,
            ),
          );
          return;
        } on NetworkException catch (e) {
          debugPrint(
            '⚠️ Network error loading settings, using local cache: $e',
          );
          // Fall through to use local storage
        } on ServerException catch (e) {
          debugPrint('⚠️ Server error loading settings, using local cache: $e');
          // Fall through to use local storage
        }
      }

      // Fallback to local storage
      emit(
        state.copyWith(
          currency: SettingsService.currency,
          isDarkMode: SettingsService.isDarkMode,
          language: SettingsService.language,
          appMode: SettingsService.appMode,
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Update currency - sync with API if available
  /// 1. Update local immediately for responsive UI
  /// 2. Send PUT /api/settings with new currency
  /// 3. After successful PUT, fetch updated settings via GET /api/settings
  /// 4. Update state and local storage with full settings from API
  Future<void> _onChangeCurrency(
    ChangeCurrency event,
    Emitter<SettingsState> emit,
  ) async {
    // Convert currency symbol to code if needed
    final currencyCode = SettingsService.getCurrencyCode(event.currency);

    try {
      // Step 1: Update local immediately for responsive UI
      await SettingsService.setCurrency(currencyCode);
      emit(
        state.copyWith(
          currency: currencyCode,
          isLoading: true,
          clearError: true,
        ),
      );

      // Step 2 & 3: Sync with API if available
      if (_apiService != null) {
        try {
          // Step 2: Send PUT /api/settings with new currency
          debugPrint(
            '📤 PUT /api/settings - Updating currency to $currencyCode',
          );
          await _apiService.updateSettings(currency: currencyCode);

          // Step 3: Fetch updated settings via GET /api/settings
          debugPrint('🔍 GET /api/settings - Fetching updated settings...');
          final updatedSettings = await _apiService.getSettings();

          // Step 4: Update local cache with full API response
          await SettingsService.setCurrency(updatedSettings.currency);
          await SettingsService.setLanguage(updatedSettings.language);
          await SettingsService.setDarkMode(updatedSettings.isDarkMode);

          // Update state with full API response to ensure sync
          emit(
            state.copyWith(
              currency: updatedSettings.currency,
              language: updatedSettings.language,
              isDarkMode: updatedSettings.isDarkMode,
              companyName: updatedSettings.companyName,
              companyLogo: updatedSettings.companyLogo,
              notifications: updatedSettings.notifications,
              // Preserve appMode from SettingsService (set from API)
              appMode: SettingsService.appMode,
              isLoading: false,
              clearError: true,
            ),
          );

          debugPrint(
            '✅ Currency updated and synced: ${updatedSettings.currency}',
          );
        } on NetworkException catch (e) {
          debugPrint('⚠️ Network error syncing currency to API: $e');
          // Keep local update, but show warning
          emit(
            state.copyWith(
              isLoading: false,
              error:
                  'Network error: Currency saved locally but not synced to server',
            ),
          );
        } on ServerException catch (e) {
          debugPrint('⚠️ Server error syncing currency to API: $e');
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Server error: ${e.message}',
            ),
          );
        } catch (e) {
          debugPrint('⚠️ Error syncing currency to API: $e');
          emit(
            state.copyWith(
              isLoading: false,
              error: 'Failed to sync currency: ${e.toString()}',
            ),
          );
        }
      } else {
        // No API service, just update local
        emit(state.copyWith(isLoading: false, clearError: true));
      }
    } catch (e) {
      debugPrint('❌ Error changing currency: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update currency: ${e.toString()}',
        ),
      );
    }
  }

  /// Update language - sync with API if available
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      // Update local immediately for responsive UI
      await SettingsService.setLanguage(event.language);
      emit(state.copyWith(language: event.language, clearError: true));

      // Sync with API if available
      if (_apiService != null) {
        try {
          final updatedSettings = await _apiService.updateSettings(
            language: event.language,
          );

          // Update local cache with full API response
          await SettingsService.setCurrency(updatedSettings.currency);
          await SettingsService.setLanguage(updatedSettings.language);
          await SettingsService.setDarkMode(updatedSettings.isDarkMode);

          // Update state with full API response to ensure sync
          emit(
            state.copyWith(
              currency: updatedSettings.currency,
              language: updatedSettings.language,
              isDarkMode: updatedSettings.isDarkMode,
              companyName: updatedSettings.companyName,
              companyLogo: updatedSettings.companyLogo,
              notifications: updatedSettings.notifications,
              // Preserve appMode from SettingsService (set from API)
              appMode: SettingsService.appMode,
              clearError: true,
            ),
          );
        } catch (e) {
          debugPrint('⚠️ Failed to sync language to API: $e');
          // Keep local update, but show warning if it's a network error
          if (e is NetworkException) {
            emit(
              state.copyWith(
                error:
                    'Network error: Settings saved locally but not synced to server',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
      emit(state.copyWith(error: 'Failed to update language: ${e.toString()}'));
    }
  }

  /// Toggle dark mode - sync with API if available
  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      // Update local immediately for responsive UI
      await SettingsService.setDarkMode(event.isDarkMode);
      emit(state.copyWith(isDarkMode: event.isDarkMode, clearError: true));

      // Sync with API if available
      if (_apiService != null) {
        try {
          final updatedSettings = await _apiService.updateSettings(
            theme: event.isDarkMode ? 'dark' : 'light',
          );

          // Update local cache with full API response
          await SettingsService.setCurrency(updatedSettings.currency);
          await SettingsService.setLanguage(updatedSettings.language);
          await SettingsService.setDarkMode(updatedSettings.isDarkMode);

          // Update state with full API response to ensure sync
          emit(
            state.copyWith(
              currency: updatedSettings.currency,
              language: updatedSettings.language,
              isDarkMode: updatedSettings.isDarkMode,
              companyName: updatedSettings.companyName,
              companyLogo: updatedSettings.companyLogo,
              notifications: updatedSettings.notifications,
              // Preserve appMode from SettingsService (set from API)
              appMode: SettingsService.appMode,
              clearError: true,
            ),
          );
        } catch (e) {
          debugPrint('⚠️ Failed to sync theme to API: $e');
          // Keep local update, but show warning if it's a network error
          if (e is NetworkException) {
            emit(
              state.copyWith(
                error:
                    'Network error: Settings saved locally but not synced to server',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error toggling dark mode: $e');
      emit(state.copyWith(error: 'Failed to update theme: ${e.toString()}'));
    }
  }

  /// Set app mode - local only (not part of API settings)
  Future<void> _onSetAppMode(
    SetAppMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await SettingsService.setAppMode(event.appMode);
      emit(state.copyWith(appMode: event.appMode, clearError: true));
    } catch (e) {
      debugPrint('❌ Error setting app mode: $e');
      emit(state.copyWith(error: 'Failed to update app mode: ${e.toString()}'));
    }
  }

  /// Change app mode - local only (not part of API settings)
  Future<void> _onChangeAppMode(
    ChangeAppMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await SettingsService.setAppMode(event.appMode);
      emit(state.copyWith(appMode: event.appMode, clearError: true));
    } catch (e) {
      debugPrint('❌ Error changing app mode: $e');
      emit(state.copyWith(error: 'Failed to update app mode: ${e.toString()}'));
    }
  }

  /// Update multiple settings via API
  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final apiService = _apiService;
    if (apiService == null) {
      emit(state.copyWith(error: 'API service not available'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final updatedSettings = await apiService.updateSettings(
        currency: event.currency,
        language: event.language,
        theme: event.theme,
        notifications: event.notifications,
        companyName: event.companyName,
        companyLogo: event.companyLogo,
      );

      // Update local cache
      if (event.currency != null) {
        await SettingsService.setCurrency(event.currency!);
      }
      if (event.language != null) {
        await SettingsService.setLanguage(event.language!);
      }
      if (event.theme != null) {
        await SettingsService.setDarkMode(event.theme == 'dark');
      }

      emit(
        state.copyWith(
          currency: updatedSettings.currency,
          language: updatedSettings.language,
          isDarkMode: updatedSettings.isDarkMode,
          companyName: updatedSettings.companyName,
          companyLogo: updatedSettings.companyLogo,
          notifications: updatedSettings.notifications,
          // Preserve appMode from SettingsService (set from API)
          appMode: SettingsService.appMode,
          isLoading: false,
          clearError: true,
        ),
      );
    } on NetworkException catch (e) {
      debugPrint('❌ Network error updating settings: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Network error: ${e.message}'),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error updating settings: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Server error: ${e.message}'),
      );
    } catch (e) {
      debugPrint('❌ Error updating settings: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update settings: ${e.toString()}',
        ),
      );
    }
  }

  /// Reset settings to default via API
  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final apiService = _apiService;
    if (apiService == null) {
      emit(state.copyWith(error: 'API service not available'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final resetSettings = await apiService.resetSettings();

      // Update local cache
      await SettingsService.setCurrency(resetSettings.currency);
      await SettingsService.setLanguage(resetSettings.language);
      await SettingsService.setDarkMode(resetSettings.isDarkMode);

      emit(
        state.copyWith(
          currency: resetSettings.currency,
          language: resetSettings.language,
          isDarkMode: resetSettings.isDarkMode,
          companyName: resetSettings.companyName,
          companyLogo: resetSettings.companyLogo,
          notifications: resetSettings.notifications,
          // Preserve appMode from SettingsService (set from API)
          appMode: SettingsService.appMode,
          isLoading: false,
          clearError: true,
        ),
      );
    } on NetworkException catch (e) {
      debugPrint('❌ Network error resetting settings: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Network error: ${e.message}'),
      );
    } on ServerException catch (e) {
      debugPrint('❌ Server error resetting settings: $e');
      emit(
        state.copyWith(isLoading: false, error: 'Server error: ${e.message}'),
      );
    } catch (e) {
      debugPrint('❌ Error resetting settings: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to reset settings: ${e.toString()}',
        ),
      );
    }
  }
}
