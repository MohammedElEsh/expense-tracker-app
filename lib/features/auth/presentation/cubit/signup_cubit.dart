import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/auth/domain/usecases/apply_user_context_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/clear_app_context_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_business_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_personal_usecase.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final RegisterPersonalUseCase _registerPersonalUseCase;
  final RegisterBusinessUseCase _registerBusinessUseCase;
  final LogoutUseCase _logoutUseCase;
  final ApplyUserContextUseCase _applyUserContextUseCase;
  final ClearAppContextUseCase _clearAppContextUseCase;

  SignupCubit({
    required RegisterPersonalUseCase registerPersonalUseCase,
    required RegisterBusinessUseCase registerBusinessUseCase,
    required LogoutUseCase logoutUseCase,
    required ApplyUserContextUseCase applyUserContextUseCase,
    required ClearAppContextUseCase clearAppContextUseCase,
  })  : _registerPersonalUseCase = registerPersonalUseCase,
        _registerBusinessUseCase = registerBusinessUseCase,
        _logoutUseCase = logoutUseCase,
        _applyUserContextUseCase = applyUserContextUseCase,
        _clearAppContextUseCase = clearAppContextUseCase,
        super(const SignupState());

  Future<void> signupPersonal({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 SignupCubit: Starting personal registration...');
      emit(state.copyWith(status: SignupStatus.loading, clearError: true));

      await _clearAppContextUseCase();

      final user = await _registerPersonalUseCase(
        RegisterPersonalParams(
          name: name.trim(),
          email: email.trim(),
          password: password,
        ),
      );

      debugPrint('✅ SignupCubit: Registration successful: ${user.email}');

      await _applyUserContextUseCase(user);
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

      await _clearAppContextUseCase();

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

      await _applyUserContextUseCase(user);
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
