// Login Feature - Cubit
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/login_state.dart';
import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

/// Login Cubit for handling email/password authentication
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  /// Create LoginCubit with optional dependency
  /// If not provided, uses ServiceLocator
  LoginCubit({LoginUseCase? loginUseCase})
    : _loginUseCase = loginUseCase ?? serviceLocator.loginUseCase,
      super(const LoginState());

  /// Handle login request with email and password
  Future<void> login({required String email, required String password}) async {
    try {
      debugPrint('🔐 LoginCubit: Starting login...');
      emit(state.copyWith(status: LoginStatus.loading, clearError: true));

      final user = await _loginUseCase(email.trim(), password);

      debugPrint('✅ LoginCubit: Login successful: ${user.email}');
      emit(state.copyWith(status: LoginStatus.success));
    } on AuthException catch (e) {
      debugPrint('❌ LoginCubit: Auth error - ${e.message}');
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.message),
      );
    } catch (error) {
      debugPrint('❌ LoginCubit: Unexpected error - $error');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: _parseErrorMessage(error),
        ),
      );
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  /// Toggle remember me preference
  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  /// Reset login state to initial
  void resetState() {
    emit(const LoginState());
  }

  /// Parse error message to user-friendly format
  String _parseErrorMessage(dynamic error) {
    final message = error.toString();

    if (message.contains('invalid credentials') ||
        message.contains('Invalid credentials') ||
        message.contains('wrong password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('user not found') ||
        message.contains('User not found')) {
      return 'No account found with this email. Please sign up.';
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
    if (message.contains('too many') || message.contains('rate limit')) {
      return 'Too many login attempts. Please try again later.';
    }

    return 'Login failed. Please try again.';
  }
}
