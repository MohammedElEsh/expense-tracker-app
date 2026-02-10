import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case for resending verification email
class ResendVerificationUseCase {
  final AuthRepository repository;

  const ResendVerificationUseCase(this.repository);

  /// Resend verification email to the given email address
  Future<void> call(String email) {
    return repository.resendVerificationEmail(email);
  }
}
