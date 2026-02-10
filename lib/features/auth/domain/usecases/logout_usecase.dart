import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';

/// Use case for user logout
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  /// Execute logout
  /// Clears stored token, session, and all cached data
  Future<void> call() async {
    // Clear user context first (clears all service caches)
    userContextManager.clearContext();

    // Clear all service caches via ServiceLocator
    await serviceLocator.reset();

    // Clear auth session
    await repository.logout();
  }
}
