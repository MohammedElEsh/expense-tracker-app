// Signup Feature - Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/signup_state.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_personal_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_business_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// Signup Cubit for handling personal and business registration
class SignupCubit extends Cubit<SignupState> {
  final RegisterPersonalUseCase _registerPersonalUseCase;
  final RegisterBusinessUseCase _registerBusinessUseCase;
  final LogoutUseCase _logoutUseCase;

  /// Create SignupCubit with optional dependencies
  /// If not provided, uses ServiceLocator
  SignupCubit({
    RegisterPersonalUseCase? registerPersonalUseCase,
    RegisterBusinessUseCase? registerBusinessUseCase,
    LogoutUseCase? logoutUseCase,
  }) : _registerPersonalUseCase =
           registerPersonalUseCase ?? serviceLocator.registerPersonalUseCase,
       _registerBusinessUseCase =
           registerBusinessUseCase ?? serviceLocator.registerBusinessUseCase,
       _logoutUseCase = logoutUseCase ?? serviceLocator.logoutUseCase,
       super(const SignupState());

  /// Handle personal signup request
  Future<void> signupPersonal({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 SignupCubit: Starting personal registration...');
      emit(state.copyWith(status: SignupStatus.loading, clearError: true));

      // 1. Clear old mode settings
      debugPrint('🧹 SignupCubit: Clearing old mode settings...');
      await SettingsService.clearModeAndCompany();

      // 2. Register via REST API
      debugPrint('🔐 SignupCubit: Registering user via API...');
      final user = await _registerPersonalUseCase(
        RegisterPersonalParams(
          name: name.trim(),
          email: email.trim(),
          password: password,
        ),
      );

      debugPrint('✅ SignupCubit: Registration successful: ${user.email}');

      // 3. Save personal mode setting
      debugPrint('💾 SignupCubit: Saving app mode...');
      await SettingsService.setAppMode(AppMode.personal);
      await SettingsService.setCompanyId(null);
      debugPrint('✅ SignupCubit: Saved mode: personal');

      // 4. Logout to force fresh login (user should verify email first or login again)
      debugPrint('🚪 SignupCubit: Logging out for fresh login...');
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

      debugPrint('✅ SignupCubit: Personal registration completed!');
    } on AuthException catch (e) {
      debugPrint('❌ SignupCubit: Registration error - ${e.message}');
      emit(
        state.copyWith(status: SignupStatus.failure, errorMessage: e.message),
      );
    } catch (error) {
      debugPrint('❌ SignupCubit: Unexpected error - $error');
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: _parseErrorMessage(error),
        ),
      );
    }
  }

  /// Handle business signup request
  Future<void> signupBusiness({
    required String companyName,
    required String adminName,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 SignupCubit: Starting business registration...');
      emit(state.copyWith(status: SignupStatus.loading, clearError: true));

      // 1. Clear old mode settings
      debugPrint('🧹 SignupCubit: Clearing old mode settings...');
      await SettingsService.clearModeAndCompany();

      // 2. Register via REST API (company is created on backend)
      debugPrint('🔐 SignupCubit: Registering business user via API...');
      final user = await _registerBusinessUseCase(
        RegisterBusinessParams(
          name: adminName.trim(),
          email: email.trim(),
          password: password,
          companyName: companyName.trim(),
        ),
      );

      debugPrint(
        '✅ SignupCubit: Business registration successful: ${user.email}',
      );
      debugPrint('🏢 SignupCubit: Company ID: ${user.companyId}');

      // 3. Save business mode setting
      debugPrint('💾 SignupCubit: Saving app mode...');
      await SettingsService.setAppMode(AppMode.business);
      if (user.companyId != null) {
        await SettingsService.setCompanyId(user.companyId);
      }
      debugPrint(
        '✅ SignupCubit: Saved mode: business with companyId: ${user.companyId}',
      );

      // 4. Logout to force fresh login (user should verify email first or login again)
      debugPrint('🚪 SignupCubit: Logging out for fresh login...');
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

      debugPrint('✅ SignupCubit: Business registration completed!');
    } on AuthException catch (e) {
      debugPrint('❌ SignupCubit: Registration error - ${e.message}');
      emit(
        state.copyWith(status: SignupStatus.failure, errorMessage: e.message),
      );
    } catch (error) {
      debugPrint('❌ SignupCubit: Unexpected error - $error');
      emit(
        state.copyWith(
          status: SignupStatus.failure,
          errorMessage: _parseErrorMessage(error),
        ),
      );
    }
  }

  /// Reset signup state to initial
  void resetState() {
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
