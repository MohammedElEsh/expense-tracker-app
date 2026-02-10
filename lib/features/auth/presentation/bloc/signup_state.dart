// Signup Feature - BLoC State
import 'package:equatable/equatable.dart';

enum SignupStatus { initial, loading, success, failure }

class SignupState extends Equatable {
  final SignupStatus status;
  final String? errorMessage;
  final String? successMessage;

  const SignupState({
    this.status = SignupStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage, successMessage];

  SignupState copyWith({
    SignupStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SignupState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get isLoading => status == SignupStatus.loading;
  bool get isSuccess => status == SignupStatus.success;
  bool get isFailure => status == SignupStatus.failure;
  bool get hasError => errorMessage != null;
}
