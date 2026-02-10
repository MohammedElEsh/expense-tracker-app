import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';

/// Centralized Dio client for all HTTP requests
/// Provides a configured Dio instance with interceptors for:
/// - Authentication token injection
/// - Request/Response logging
/// - Error handling
class DioClient {
  static const String _baseUrl = 'https://expense-tracker-app-5.onrender.com';

  late final Dio _dio;
  final PrefHelper _prefHelper;

  DioClient(this._prefHelper) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _initializeInterceptors();
  }

  /// Initialize Dio interceptors
  void _initializeInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token to requests
          final token = await _prefHelper.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('🌐 API Request: ${options.method} ${options.path}');
          debugPrint('📦 Request Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          debugPrint('📦 Response Data: ${response.data}');

          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
            '❌ API Error: ${error.response?.statusCode} ${error.message}',
          );
          debugPrint('📦 Error Data: ${error.response?.data}');

          return handler.next(error);
        },
      ),
    );
  }

  /// Get the configured Dio instance
  Dio get dio => _dio;

  /// Update base URL (useful for testing or environment switching)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom interceptor
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Clear all interceptors and reinitialize
  void resetInterceptors() {
    _initializeInterceptors();
  }
}
