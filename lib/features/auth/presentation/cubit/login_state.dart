// Login Feature - Cubit State
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool rememberMe;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    isPasswordVisible,
    rememberMe,
  ];

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? rememberMe,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isFailure => status == LoginStatus.failure;
}
