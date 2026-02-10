import 'package:dio/dio.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

/// Centralized API service for handling HTTP requests and responses
/// Provides error handling and response parsing for all API calls
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// Parse error response to readable message and throw appropriate exception
  static Never handleError(dynamic error) {
    if (error is DioException) {
      final response = error.response;

      // Handle response errors
      if (response != null && response.data != null) {
        final message = _extractErrorMessage(response.data);
        final statusCode = response.statusCode;

        // Throw specific exceptions based on status code
        switch (statusCode) {
          case 400:
            throw ValidationException(message);
          case 401:
            throw UnauthorizedException(message);
          case 403:
            throw ForbiddenException(message);
          case 404:
            throw NotFoundException(message);
          default:
            throw ServerException(message, statusCode: statusCode);
        }
      }

      // Handle network errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw NetworkException(
            'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.connectionError:
          throw NetworkException(
            'Unable to connect to server. Please check your internet connection.',
          );
        case DioExceptionType.cancel:
          throw NetworkException('Request was cancelled.');
        default:
          throw ServerException(
            error.message ?? 'An unexpected error occurred',
          );
      }
    }

    // Handle other errors
    throw ServerException(error?.toString() ?? 'An unexpected error occurred');
  }

  /// Extract error message from response data
  static String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'An unexpected error occurred';
    }
    return data.toString();
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      handleError(e);
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } catch (e) {
      handleError(e);
    }
  }
}
