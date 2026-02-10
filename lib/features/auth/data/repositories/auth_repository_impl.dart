import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';

/// Implementation of AuthRepository using REST API
class AuthRepositoryImpl implements AuthRepository {
  // Stream controller for auth state changes
  final StreamController<UserEntity?> _authStateController =
      StreamController<UserEntity?>.broadcast();

  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource {
    // Check initial auth state
    _checkInitialAuthState();
  }

  /// Check initial authentication state on startup
  Future<void> _checkInitialAuthState() async {
    try {
      final user = await getCurrentUser();
      _authStateController.add(user);
    } catch (e) {
      debugPrint('⚠️ No authenticated user on startup');
      _authStateController.add(null);
    }
  }

  @override
  Future<UserEntity> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      _authStateController.add(response.user);

      return response.user;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> registerPersonal({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        accountType: 'personal',
        phone: phone,
      );

      // Don't set current user after registration
      // User needs to verify email first (depending on backend config)
      // Or login again after registration

      return response.user;
    } catch (e) {
      debugPrint('❌ Personal registration failed: $e');
      rethrow;
    }
  }

  @override
  Future<UserEntity> registerBusiness({
    required String name,
    required String email,
    required String password,
    required String companyName,
    String? phone,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        accountType: 'business',
        companyName: companyName,
        phone: phone,
      );

      // Don't set current user after registration
      // User needs to verify email first (depending on backend config)
      // Or login again after registration

      return response.user;
    } catch (e) {
      debugPrint('❌ Business registration failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      _authStateController.add(null);
    } catch (e) {
      // Always clear local state even if API fails
      _authStateController.add(null);
      debugPrint('⚠️ Logout completed with warning: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _remoteDataSource.isAuthenticated();
  }

  @override
  Future<void> verifyEmail(String token) async {
    await _remoteDataSource.verifyEmail(token);
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    await _remoteDataSource.resendVerificationEmail(email);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _authStateController.stream;
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
