// Signup Feature - BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_personal_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_business_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// Signup BLoC for handling personal and business registration
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final RegisterPersonalUseCase _registerPersonalUseCase;
  final RegisterBusinessUseCase _registerBusinessUseCase;
  final LogoutUseCase _logoutUseCase;

  /// Create SignupBloc with optional dependencies
  /// If not provided, uses ServiceLocator
  SignupBloc({
    RegisterPersonalUseCase? registerPersonalUseCase,
    RegisterBusinessUseCase? registerBusinessUseCase,
    LogoutUseCase? logoutUseCase,
  }) : _registerPersonalUseCase =
           registerPersonalUseCase ?? serviceLocator.registerPersonalUseCase,
       _registerBusinessUseCase =
           registerBusinessUseCase ?? serviceLocator.registerBusinessUseCase,
       _logoutUseCase = logoutUseCase ?? serviceLocator.logoutUseCase,
       super(const SignupState()) {
    on<SignupPersonalRequested>(_onSignupPersonalRequested);
    on<SignupBusinessRequested>(_onSignupBusinessRequested);
    on<ResetSignupState>(_onResetSignupState);
  }

  /// Handle personal signup request
  Future<void> _onSignupPersonalRequested(
    SignupPersonalRequested event,
    Emitter<SignupState> emit,
  ) async {
    try {
      debugPrint('📝 SignupBloc: Starting personal registration...');
      emit(state.copyWith(status: SignupStatus.loading, clearError: true));

      // 1. Clear old mode settings
      debugPrint('🧹 SignupBloc: Clearing old mode settings...');
      await SettingsService.clearModeAndCompany();

      // 2. Register via REST API
      debugPrint('🔐 SignupBloc: Registering user via API...');
      final user = await _registerPersonalUseCase(
        RegisterPersonalParams(
          name: event.name.trim(),
          email: event.email.trim(),
          password: event.password,
        ),
      );

      debugPrint('✅ SignupBloc: Registration successful: ${user.email}');

      // 3. Save personal mode setting
      debugPrint('💾 SignupBloc: Saving app mode...');
      await SettingsService.setAppMode(AppMode.personal);
      await SettingsService.setCompanyId(null);
      debugPrint('✅ SignupBloc: Saved mode: personal');

      // 4. Logout to force fresh login (user should verify email first or login again)
      debugPrint('🚪 SignupBloc: Logging out for fresh login...');
      await _logoutUseCase();

      emit(
        state.copyWith(
          status: SignupStatus.success,
          successMessage:
              user.isVerified
                  ? 'Personal account created successfully! Please login.'
                  : 'Account created! Please check your email to verify your account.',
        ),
      );

      debugPrint('✅ SignupBloc: Personal registration completed!');
    } on AuthException catch (e) {
      debugPrint('❌ SignupBloc: Registration error - ${e.message}');
      emit(
        state.copyWith(status: SignupStatus.failure, errorMessage: e.message),
      );
    } catch (error) {
      debugPrint('❌ SignupBloc: Unexpected error - $error');
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: _parseErrorMessage(error),
        ),
      );
    }
  }

  /// Handle business signup request
  Future<void> _onSignupBusinessRequested(
    SignupBusinessRequested event,
    Emitter<SignupState> emit,
  ) async {
    try {
      debugPrint('📝 SignupBloc: Starting business registration...');
      emit(state.copyWith(status: SignupStatus.loading, clearError: true));

      // 1. Clear old mode settings
      debugPrint('🧹 SignupBloc: Clearing old mode settings...');
      await SettingsService.clearModeAndCompany();

      // 2. Register via REST API (company is created on backend)
      debugPrint('🔐 SignupBloc: Registering business user via API...');
      final user = await _registerBusinessUseCase(
        RegisterBusinessParams(
          name: event.adminName.trim(),
          email: event.email.trim(),
          password: event.password,
          companyName: event.companyName.trim(),
        ),
      );

      debugPrint(
        '✅ SignupBloc: Business registration successful: ${user.email}',
      );
      debugPrint('🏢 SignupBloc: Company ID: ${user.companyId}');

      // 3. Save business mode setting
      debugPrint('💾 SignupBloc: Saving app mode...');
      await SettingsService.setAppMode(AppMode.business);
      if (user.companyId != null) {
        await SettingsService.setCompanyId(user.companyId);
      }
      debugPrint(
        '✅ SignupBloc: Saved mode: business with companyId: ${user.companyId}',
      );

      // 4. Logout to force fresh login (user should verify email first or login again)
      debugPrint('🚪 SignupBloc: Logging out for fresh login...');
      await _logoutUseCase();

      emit(
        state.copyWith(
          status: SignupStatus.success,
          successMessage:
              user.isVerified
                  ? 'Business account created successfully! Please login.'
                  : 'Account created! Please check your email to verify your account.',
        ),
      );

      debugPrint('✅ SignupBloc: Business registration completed!');
    } on AuthException catch (e) {
      debugPrint('❌ SignupBloc: Registration error - ${e.message}');
      emit(
        state.copyWith(status: SignupStatus.failure, errorMessage: e.message),
      );
    } catch (error) {
      debugPrint('❌ SignupBloc: Unexpected error - $error');
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: _parseErrorMessage(error),
        ),
      );
    }
  }

  /// Reset signup state to initial
  void _onResetSignupState(ResetSignupState event, Emitter<SignupState> emit) {
    emit(const SignupState());
  }

  /// Parse error message to user-friendly format
  String _parseErrorMessage(dynamic error) {
    final message = error.toString();

    // Common error translations
    if (message.contains('email already') ||
        message.contains('Email already') ||
        message.contains('already registered')) {
      return 'This email is already registered. Please login or use a different email.';
    }
    if (message.contains('weak password') ||
        message.contains('Password must')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    if (message.contains('invalid email') ||
        message.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (message.contains('timeout')) {
      return 'Request timeout. Please try again.';
    }

    return 'Error creating account. Please try again.';
  }
}
