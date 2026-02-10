import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';

// =============================================================================
// AUTH REMOTE DATA SOURCE - Clean Architecture Implementation
// =============================================================================

/// Remote data source for authentication using REST API
/// Uses core services: ApiService, PrefHelper
/// No Firebase dependencies - pure REST API implementation
class AuthRemoteDataSource {
  final ApiService _apiService;
  final PrefHelper _prefHelper;

  // Cache for current user data
  UserModel? _cachedUser;

  AuthRemoteDataSource({
    required ApiService apiService,
    required PrefHelper prefHelper,
  }) : _apiService = apiService,
       _prefHelper = prefHelper;

  // ===========================================================================
  // USER CACHE MANAGEMENT
  // ===========================================================================

  /// Cache user data locally
  Future<void> _cacheUser(UserModel user) async {
    try {
      _cachedUser = user;
      await _prefHelper.saveUserId(user.id);
      await _prefHelper.saveUserData(user.toJson().toString());
      debugPrint('✅ User cached: ${user.email}');
    } catch (e) {
      debugPrint('❌ Error caching user: $e');
    }
  }

  /// Get cached user
  UserModel? get cachedUser => _cachedUser;

  /// Get cached user ID
  Future<String?> getCachedUserId() async {
    if (_cachedUser != null) return _cachedUser!.id;
    return await _prefHelper.getUserId();
  }

  /// Clear cached user data
  Future<void> _clearUserCache() async {
    _cachedUser = null;
    await _prefHelper.clearUserData();
  }

  // ===========================================================================
  // API METHODS
  // ===========================================================================

  /// Register a new user (personal or business)
  /// POST /api/auth/register
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String accountType,
    String? companyName,
    String? phone,
  }) async {
    try {
      debugPrint('📝 Registering new user: $email ($accountType)');

      final Map<String, dynamic> body = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'accountType': accountType,
      };

      if (accountType == 'business' && companyName != null) {
        body['companyName'] = companyName.trim();
      }

      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone.trim();
      }

      final response = await _apiService.post('/api/auth/register', data: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(response.data);
        await _prefHelper.saveAuthToken(authResponse.token);
        await _cacheUser(authResponse.user);
        debugPrint('✅ Registration successful: ${authResponse.user.email}');
        return authResponse;
      }

      throw AuthException('Registration failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('❌ Unexpected registration error: $e');
      throw AuthException('Registration failed: $e');
    }
  }

  /// Login with email and password
  /// POST /api/auth/login
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Logging in: $email');

      final response = await _apiService.post(
        '/api/auth/login',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Check if user is active
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null && user['isActive'] == false) {
          throw AccountDeactivatedException(
            'Your account has been deactivated. Please contact support.',
          );
        }

        // Check if email is verified (optional - depends on backend config)
        if (user != null && user['isVerified'] == false) {
          throw EmailNotVerifiedException(
            'Please verify your email before logging in.',
            email: email,
          );
        }

        final authResponse = AuthResponseModel.fromJson(data);
        await _prefHelper.saveAuthToken(authResponse.token);
        await _cacheUser(authResponse.user);
        debugPrint('✅ Login successful: ${authResponse.user.email}');
        return authResponse;
      }

      throw AuthException('Login failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('❌ Unexpected login error: $e');
      throw AuthException('Login failed: $e');
    }
  }

  /// Get current authenticated user
  /// GET /api/auth/me
  Future<UserModel> getCurrentUser() async {
    try {
      debugPrint('👤 Fetching current user...');

      final token = await _prefHelper.getAuthToken();
      if (token == null || token.isEmpty) {
        throw AuthException('Not authenticated');
      }

      final response = await _apiService.get('/api/auth/me');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);

        if (!user.isActive) {
          await _prefHelper.clearAuthData();
          await _clearUserCache();
          throw AccountDeactivatedException(
            'Your account has been deactivated. Please contact support.',
          );
        }

        await _cacheUser(user);
        debugPrint('✅ Current user: ${user.email}');
        return user;
      }

      throw AuthException('Failed to fetch user');
    } on UnauthorizedException {
      await _prefHelper.clearAuthData();
      await _clearUserCache();
      throw AuthException('Session expired. Please login again.');
    } catch (e) {
      if (e is AuthException) rethrow;
      debugPrint('❌ Unexpected error fetching user: $e');
      throw AuthException('Failed to fetch user: $e');
    }
  }

  /// Logout current user
  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      debugPrint('🚪 Logging out...');

      final token = await _prefHelper.getAuthToken();
      if (token != null && token.isNotEmpty) {
        try {
          await _apiService.post('/api/auth/logout');
        } catch (e) {
          debugPrint('⚠️ Logout API error (ignored): $e');
        }
      }

      await _prefHelper.clearAuthData();
      await _clearUserCache();
      debugPrint('✅ Logout successful');
    } catch (e) {
      await _prefHelper.clearAuthData();
      await _clearUserCache();
      debugPrint('⚠️ Logout completed with warning: $e');
    }
  }

  /// Verify email with token
  /// GET /api/auth/verify-email/:token
  Future<void> verifyEmail(String token) async {
    try {
      debugPrint('📧 Verifying email...');

      final response = await _apiService.get('/api/auth/verify-email/$token');

      if (response.statusCode == 200) {
        debugPrint('✅ Email verified successfully');
        return;
      }

      throw AuthException('Email verification failed');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Email verification failed: $e');
    }
  }

  /// Resend verification email
  /// POST /api/auth/resend-verification
  Future<void> resendVerificationEmail(String email) async {
    try {
      debugPrint('📧 Resending verification email to: $email');

      final response = await _apiService.post(
        '/api/auth/resend-verification',
        data: {'email': email.trim().toLowerCase()},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Verification email sent');
        return;
      }

      throw AuthException('Failed to resend verification email');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to resend verification email: $e');
    }
  }

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    final token = await _prefHelper.getAuthToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user data as Map (for backward compatibility)
  /// Returns user data from cache or fetches from API
  Future<Map<String, dynamic>?> getUserData(
    String userId, {
    int maxRetries = 5,
    Duration retryDelay = const Duration(milliseconds: 500),
  }) async {
    // First, try cached user
    if (_cachedUser != null) {
      debugPrint('✅ Using cached user data from REST API');
      return _userModelToMap(_cachedUser!);
    }

    // Try to get current user from REST API
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('🔄 Fetching user from REST API... ($attempt/$maxRetries)');
        final user = await getCurrentUser();
        debugPrint('✅ Got user data from REST API');
        return _userModelToMap(user);
      } catch (e) {
        debugPrint('❌ REST API error on attempt $attempt: $e');
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    debugPrint('❌ Failed to fetch user after $maxRetries attempts');
    return null;
  }

  /// Convert UserModel to Map for backward compatibility
  Map<String, dynamic> _userModelToMap(UserModel user) {
    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.name,
      'name': user.name,
      'accountType': user.accountType,
      'companyId': user.companyId,
      'companyName': user.companyName,
      'role': user.role,
      'isActive': user.isActive,
      'isVerified': user.isVerified,
      'phone': user.phone,
      'createdAt': user.createdAt,
      'lastLogin': user.lastLogin,
    };
  }

  /// Update user role
  /// Note: This requires a separate user management API endpoint
  Future<void> updateUserRole(String userId, String newRole) async {
    debugPrint('⚠️ updateUserRole called: userId=$userId, newRole=$newRole');
    debugPrint(
      '📝 Note: User role updates should be handled by user management API',
    );
    // This is a stub - implement when backend has user management API
    // For now, role updates are handled locally by the users feature
  }
}
