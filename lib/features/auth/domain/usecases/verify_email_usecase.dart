import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case for email verification
class VerifyEmailUseCase {
  final AuthRepository repository;

  const VerifyEmailUseCase(this.repository);

  /// Verify email with token from verification link
  Future<void> call(String token) {
    return repository.verifyEmail(token);
  }
}
