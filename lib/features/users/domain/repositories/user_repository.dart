import 'package:expense_tracker/features/users/data/models/user.dart';

/// Abstract repository interface for user management operations.
///
/// Defines the contract for user data access (business mode only).
/// All mutation operations are restricted to the company owner.
abstract class UserRepository {
  /// Get all users in the company.
  ///
  /// Returns a list of raw user data maps from the API.
  Future<List<Map<String, dynamic>>> getAllUsers();

  /// Get a single user by their [userId].
  ///
  /// Returns `null` if not found.
  Future<Map<String, dynamic>?> getUserById(String userId);

  /// Add a new user to the company.
  ///
  /// Only the owner can add users. The [role] cannot be [UserRole.owner].
  /// Returns the created user data map.
  Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Update a user's details (name and/or role).
  ///
  /// Only the owner can update users. At least one of [name] or [role]
  /// must be provided. Returns the updated user data map.
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? name,
    UserRole? role,
  });

  /// Delete a user from the company.
  ///
  /// Only the owner can delete users.
  Future<void> deleteUser(String userId);
}
