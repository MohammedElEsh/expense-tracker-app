import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/domain/usecases/apply_user_context_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/login_state.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final ResendVerificationUseCase _resendVerificationUseCase;
  final ApplyUserContextUseCase _applyUserContextUseCase;

  LoginCubit({
    required LoginUseCase loginUseCase,
    required ResendVerificationUseCase resendVerificationUseCase,
    required ApplyUserContextUseCase applyUserContextUseCase,
  })  : _loginUseCase = loginUseCase,
        _resendVerificationUseCase = resendVerificationUseCase,
        _applyUserContextUseCase = applyUserContextUseCase,
        super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    try {
      debugPrint('🔐 LoginCubit: Starting login...');
      emit(state.copyWith(status: LoginStatus.loading, clearError: true));

      final user = await _loginUseCase(email.trim(), password);
      debugPrint('✅ LoginCubit: Login successful: ${user.email}');

      await _applyUserContextUseCase(user);
      await Future.delayed(const Duration(milliseconds: 300));

      emit(state.copyWith(
        status: LoginStatus.success,
        loggedInUser: user,
        clearError: true,
      ));
    } on AccountDeactivatedException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
        clearError: false,
      ));
    } on EmailNotVerifiedException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
        clearError: false,
      ));
    } on AuthException catch (e) {
      debugPrint('❌ LoginCubit: Auth error - ${e.message}');
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
        clearError: false,
      ));
    } catch (error) {
      debugPrint('❌ LoginCubit: Unexpected error - $error');
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: _parseErrorMessage(error),
        clearError: false,
      ));
    }
  }

  /// Resend verification email (e.g. when EmailNotVerified is shown).
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _resendVerificationUseCase(email.trim());
    } catch (_) {
      rethrow;
    }
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  void resetState() {
    emit(const LoginState());
  }

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
