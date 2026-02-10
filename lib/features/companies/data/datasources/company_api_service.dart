import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';

// =============================================================================
// COMPANY API SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Response model for company operations
class CompanyResponse {
  final bool success;
  final Company? company;
  final String? message;

  CompanyResponse({
    required this.success,
    this.company,
    this.message,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      success: json['success'] as bool? ?? false,
      company: json['company'] != null
          ? Company.fromApiJson(json['company'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}

/// Remote data source for companies using REST API
/// Uses core services: ApiService
class CompanyApiService {
  final ApiService _apiService;

  // Cache for company
  Company? _cachedCompany;
  DateTime? _lastFetchTime;

  // Cache duration: 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  CompanyApiService({required ApiService apiService})
      : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_cachedCompany == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  /// Clear cached company
  void clearCache() {
    _cachedCompany = null;
    _lastFetchTime = null;
    debugPrint('🗑️ Company cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Create a new company
  /// POST /api/company
  ///
  /// Request Body:
  /// {
  ///   "name": "Company Name",
  ///   "taxNumber": "300123456789012",
  ///   "address": "Address",
  ///   "phone": "0555123456",
  ///   "currency": "SAR"
  /// }
  Future<Company> createCompany(Company company) async {
    try {
      final currentAppMode = SettingsService.appMode;

      // Only business mode can create companies
      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Companies are only available in business mode',
        );
      }

      debugPrint('➕ Creating company: ${company.name}');

      // Build request body
      final requestBody = company.toApiJson();

      debugPrint('📤 POST /api/company');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/company',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final companyResponse = CompanyResponse.fromJson(responseData);

        if (companyResponse.success && companyResponse.company != null) {
          final newCompany = companyResponse.company!;

          // Clear cache to force fresh reload
          clearCache();

          debugPrint('✅ Company created successfully: ${newCompany.id}');
          return newCompany;
        } else {
          // Handle error message from API
          final errorMessage = companyResponse.message ?? 'Failed to create company';
          throw ValidationException(errorMessage);
        }
      }

      throw ServerException(
        'Failed to create company',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating company: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to create company: $e');
    }
  }

  /// Get my company
  /// GET /api/company/me
  Future<Company?> getMyCompany({bool forceRefresh = false}) async {
    try {
      final currentAppMode = SettingsService.appMode;

      // Only business mode can access companies
      if (currentAppMode != AppMode.business) {
        return null;
      }

      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid) {
        return _cachedCompany;
      }

      debugPrint('🔍 Loading my company');

      final response = await _apiService.get('/api/company/me');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final companyResponse = CompanyResponse.fromJson(responseData);

        if (companyResponse.success && companyResponse.company != null) {
          final company = companyResponse.company!;

          // Cache the company
          _cachedCompany = company;
          _lastFetchTime = DateTime.now();

          debugPrint('✅ Loaded company: ${company.name}');
          return company;
        } else {
          // No company found
          debugPrint('ℹ️ No company found');
          return null;
        }
      }

      if (response.statusCode == 404) {
        return null;
      }

      throw ServerException(
        'Failed to get company',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading company: $e');
      if (e is NotFoundException) return null;
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading company: $e');
    }
  }

  /// Update my company
  /// PUT /api/company/me
  ///
  /// Request Body:
  /// {
  ///   "name": "New Name",
  ///   "taxNumber": "300123456789012",
  ///   "address": "New Address",
  ///   "phone": "0555123456",
  ///   "currency": "SAR"
  /// }
  Future<Company> updateCompany(Company company) async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Companies are only available in business mode',
        );
      }

      debugPrint('✏️ Updating company: ${company.id}');

      // Build request body with only updatable fields
      final requestBody = company.toApiJson();

      debugPrint('📤 PUT /api/company/me');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.put(
        '/api/company/me',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final companyResponse = CompanyResponse.fromJson(responseData);

        if (companyResponse.success && companyResponse.company != null) {
          final updatedCompany = companyResponse.company!;

          // Clear cache
          clearCache();

          debugPrint('✅ Company updated successfully');
          return updatedCompany;
        } else {
          final errorMessage = companyResponse.message ?? 'Failed to update company';
          throw ValidationException(errorMessage);
        }
      }

      throw ServerException(
        'Failed to update company',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating company: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to update company: $e');
    }
  }

  /// Delete my company
  /// DELETE /api/company/me
  Future<void> deleteCompany() async {
    try {
      final currentAppMode = SettingsService.appMode;

      if (currentAppMode != AppMode.business) {
        throw ValidationException(
          'Companies are only available in business mode',
        );
      }

      debugPrint('🗑️ Deleting company');

      final response = await _apiService.delete('/api/company/me');

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear cache
        clearCache();

        debugPrint('✅ Company deleted successfully');
        return;
      }

      throw ServerException(
        'Failed to delete company',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting company: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Failed to delete company: $e');
    }
  }
}

