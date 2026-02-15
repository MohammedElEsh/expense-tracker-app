// Login Feature - Cubit State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool rememberMe;
  /// Set on success; used by listener to navigate (screen does not read user, only status).
  final UserEntity? loggedInUser;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.loggedInUser,
  });

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        isPasswordVisible,
        rememberMe,
        loggedInUser,
      ];

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? rememberMe,
    UserEntity? loggedInUser,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      loggedInUser: loggedInUser ?? this.loggedInUser,
    );
  }

  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;
}
