import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case for checking authentication status
class CheckUserStatusUseCase {
  final AuthRepository repository;

  const CheckUserStatusUseCase(this.repository);

  /// Stream of authentication state changes
  /// Emits [UserEntity] when authenticated, null when not
  Stream<UserEntity?> call() => repository.authStateChanges();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() => repository.isAuthenticated();

  /// Get current user if authenticated
  Future<UserEntity?> getCurrentUser() => repository.getCurrentUser();
}
