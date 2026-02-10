/// Base exception for server errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ServerException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

/// Exception for cache/local storage errors
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => message;
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  AuthException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

/// Custom exception for deactivated accounts
class AccountDeactivatedException extends AuthException {
  AccountDeactivatedException(super.message);
}

/// Custom exception for unverified email
class EmailNotVerifiedException extends AuthException {
  final String email;
  EmailNotVerifiedException(super.message, {required this.email});
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? errors;

  ValidationException(this.message, {this.errors});

  @override
  String toString() => message;
}

/// Exception for unauthorized access
class UnauthorizedException extends ServerException {
  UnauthorizedException(super.message);
}

/// Exception for forbidden access
class ForbiddenException extends ServerException {
  ForbiddenException(super.message);
}

/// Exception for resource not found
class NotFoundException extends ServerException {
  NotFoundException(super.message);
}
