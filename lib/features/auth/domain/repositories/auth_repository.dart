import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';

/// Authentication repository interface
/// Defines all authentication operations for the domain layer
abstract class AuthRepository {
  /// Login with email and password
  /// Returns [UserEntity] on success
  /// Throws [AuthException] on failure
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  });

  /// Register a new personal account
  /// Returns [UserEntity] on success
  /// Throws [AuthException] on failure
  Future<UserEntity> registerPersonal({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// Register a new business account
  /// Returns [UserEntity] on success
  /// Throws [AuthException] on failure
  Future<UserEntity> registerBusiness({
    required String name,
    required String email,
    required String password,
    required String companyName,
    String? phone,
  });

  /// Logout current user
  /// Clears stored token and session
  Future<void> logout();

  /// Get current authenticated user
  /// Returns [UserEntity] if authenticated, null otherwise
  /// Throws [AuthException] if token is invalid
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  /// Returns true if valid token exists
  Future<bool> isAuthenticated();

  /// Verify email with token
  /// Called when user clicks verification link
  Future<void> verifyEmail(String token);

  /// Resend verification email
  /// Used when user needs a new verification email
  Future<void> resendVerificationEmail(String email);

  /// Stream of authentication state changes
  /// Emits [UserEntity] when authenticated, null when not
  Stream<UserEntity?> authStateChanges();
}
