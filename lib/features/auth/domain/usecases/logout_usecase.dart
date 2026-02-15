import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case for user logout. Clears session and app context via repository only.
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}
