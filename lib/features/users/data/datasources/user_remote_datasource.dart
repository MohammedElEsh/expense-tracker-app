import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/users/data/models/user_model.dart';

/// Remote data source for company users. Uses ApiService (company scoped via auth).
class UserRemoteDataSource {
  final ApiService _apiService;

  UserRemoteDataSource({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<List<UserModel>> getUsers() async {
    try {
      debugPrint('🔍 Fetching all company users...');
      final response = await _apiService.get('/api/users');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['users'] ?? response.data['data'] ?? []);
        final users = data
            .map((e) => UserModel.fromApiMap(e as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Loaded ${users.length} users from API');
        return users;
      }
      throw ServerException(
        'Failed to load users',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading users: $e');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error loading users: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      if (userId.isEmpty) return null;
      final response = await _apiService.get('/api/users/$userId');
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromApiMap(userData as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user: $e');
      return null;
    }
  }

  Future<UserModel> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      if (role == 'owner') {
        throw ValidationException('Cannot assign owner role via add user');
      }
      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
      final response = await _apiService.post('/api/users', data: requestBody);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final userData = responseData['user'] ?? responseData;
        return UserModel.fromApiMap(userData as Map<String, dynamic>);
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

  Future<UserModel> updateUserName({required String userId, required String name}) async {
    if (userId.isEmpty) throw ValidationException('User ID is required');
    final response = await _apiService.put(
      '/api/users/$userId',
      data: {'name': name},
    );
    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final userData = responseData['user'] ?? responseData;
      return UserModel.fromApiMap(userData as Map<String, dynamic>);
    }
    throw ServerException(
      'Failed to update user name',
      statusCode: response.statusCode,
    );
  }

  Future<UserModel> updateUserRole({required String userId, required String role}) async {
    if (userId.isEmpty) throw ValidationException('User ID is required');
    if (role == 'owner') throw ValidationException('Cannot assign owner role via update');
    final response = await _apiService.put(
      '/api/users/$userId/role',
      data: {'role': role},
    );
    if (response.statusCode == 200) {
      final responseData = response.data as Map<String, dynamic>;
      final userData = responseData['user'] ?? responseData;
      return UserModel.fromApiMap(userData as Map<String, dynamic>);
    }
    throw ServerException(
      'Failed to update user role',
      statusCode: response.statusCode,
    );
  }

  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) return;
    final response = await _apiService.delete('/api/users/$userId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        'Failed to delete user',
        statusCode: response.statusCode,
      );
    }
  }
}
