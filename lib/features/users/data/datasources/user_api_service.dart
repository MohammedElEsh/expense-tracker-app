import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

/// User API Service - Remote data source for user management
/// Handles all API calls related to user management (Business mode only)
/// Endpoints:
/// - GET /api/users - Get all company users
/// - POST /api/users - Add new user (Owner only)
/// - PUT /api/users/:id - Update user name (Owner only)
/// - PUT /api/users/:id/role - Update user role (Owner only)
/// - DELETE /api/users/:id - Delete user (Owner only)
class UserApiService {
  final ApiService _apiService;

  UserApiService({required ApiService apiService}) : _apiService = apiService;

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Get all company users
  /// GET /api/users
  /// Returns list of users in the company
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      debugPrint('🔍 Fetching all company users...');

      final response = await _apiService.get('/api/users');

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data is List
                ? response.data
                : (response.data['users'] ?? response.data['data'] ?? []);

        final users = data.cast<Map<String, dynamic>>().toList();

        debugPrint('✅ Loaded ${users.length} users from API');
        return users;
      }

      throw ServerException(
        'Failed to load users',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading users: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading users: $e');
    }
  }

  /// Add a new user (Employee, Accountant, or Auditor)
  /// POST /api/users
  /// Only Owner can add users
  ///
  /// Request Body:
  /// {
  ///   "name": "User Name",
  ///   "email": "user@example.com",
  ///   "password": "Password123!@#",
  ///   "role": "employee" | "accountant" | "auditor"
  /// }
  Future<Map<String, dynamic>> addUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      debugPrint('➕ Adding new user: $name ($email) as ${role.name}');

      // Owner role cannot be assigned via this endpoint
      if (role == UserRole.owner) {
        throw ValidationException('Cannot assign owner role via add user');
      }

      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'role': role.name,
      };

      debugPrint('📤 POST /api/users');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post('/api/users', data: requestBody);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;

        debugPrint(
          '✅ User created successfully: ${userData['_id'] ?? userData['id']}',
        );
        return userData as Map<String, dynamic>;
      }

      throw ServerException(
        'Failed to create user',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to create user: $e');
    }
  }

  /// Update user name
  /// PUT /api/users/:id
  /// Only Owner can update users
  Future<Map<String, dynamic>> updateUserName({
    required String userId,
    required String name,
  }) async {
    try {
      if (userId.isEmpty) {
        debugPrint('⚠️ Empty userId - skipping name update');
        throw ValidationException('User ID is required');
      }

      debugPrint('🔄 Updating user name: $userId');

      final requestBody = {'name': name};

      debugPrint('📤 PUT /api/users/$userId');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.put(
        '/api/users/$userId',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;

        debugPrint('✅ User name updated successfully: $userId');
        return userData as Map<String, dynamic>;
      }

      throw ServerException(
        'Failed to update user name',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating user name: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error updating user name: $e');
    }
  }

  /// Update user role
  /// PUT /api/users/:id/role
  /// Only Owner can update roles. Cannot assign [UserRole.owner].
  Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    try {
      if (userId.isEmpty) {
        debugPrint('⚠️ Empty userId - skipping role update');
        throw ValidationException('User ID is required');
      }

      if (role == UserRole.owner) {
        throw ValidationException('Cannot assign owner role via update');
      }

      debugPrint('🔄 Updating user role: $userId -> ${role.name}');

      final requestBody = {'role': role.name};

      debugPrint('📤 PUT /api/users/$userId/role');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.put(
        '/api/users/$userId/role',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;

        debugPrint('✅ User role updated successfully: $userId');
        return userData as Map<String, dynamic>;
      }

      throw ServerException(
        'Failed to update user role',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating user role: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error updating user role: $e');
    }
  }

  /// Update user details (name and/or role)
  /// Calls [updateUserName] and/or [updateUserRole] as needed.
  /// Only Owner can update users.
  /// At least one of [name] or [role] must be provided.
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    String? name,
    UserRole? role,
  }) async {
    if (name == null && role == null) {
      throw ValidationException(
        'At least one field (name or role) must be provided',
      );
    }

    Map<String, dynamic>? lastResult;

    if (name != null) {
      lastResult = await updateUserName(userId: userId, name: name);
    }
    if (role != null) {
      lastResult = await updateUserRole(userId: userId, role: role);
    }

    return lastResult!;
  }

  /// Delete user from company
  /// DELETE /api/users/:id
  /// Only Owner can delete users
  Future<void> deleteUser(String userId) async {
    try {
      if (userId.isEmpty) {
        debugPrint('⚠️ Empty userId - skipping delete');
        return;
      }

      debugPrint('🗑️ Deleting user: $userId');

      final response = await _apiService.delete('/api/users/$userId');

      debugPrint('📥 Delete response status: ${response.statusCode}');
      debugPrint('📥 Delete response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ User deleted successfully: $userId');
        return;
      }

      throw ServerException(
        'Failed to delete user',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error deleting user: $e');
    }
  }

  /// Get a single user by ID
  /// GET /api/users/:id
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      if (userId.isEmpty) {
        debugPrint('⚠️ Empty userId - skipping fetch');
        return null;
      }

      debugPrint('🔍 Fetching user: $userId');

      final response = await _apiService.get('/api/users/$userId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;
        return userData as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user: $e');
      return null;
    }
  }
}
