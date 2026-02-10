import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';

// =============================================================================
// VENDOR SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Remote data source for vendors using REST API
/// Uses core services: ApiService
/// No Firebase dependencies - pure REST API implementation
class VendorService {
  final ApiService _apiService;

  // Cache for vendors
  List<Vendor>? _cachedVendors;

  VendorService({required ApiService apiService}) : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached vendors
  void clearCache() {
    _cachedVendors = null;
    debugPrint('🗑️ Vendor cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Create a new vendor via API
  /// POST /api/vendors
  ///
  /// Request Body:
  /// {
  ///   "name": "كارفور مصر",
  ///   "companyName": "شركة كارفور للتجارة",
  ///   "type": "supplier",
  ///   "email": "purchases@carrefour.eg",
  ///   "phone": "01001234567",
  ///   "taxNumber": "123-456-789",
  ///   "commercialRegistration": "987654321",
  ///   "contactPerson": "أحمد محمد",
  ///   "bankAccount": "EG380019000500000000123456789",
  ///   "address": "القاهرة - مدينة نصر",
  ///   "notes": "مورد رئيسي للمواد الغذائية"
  /// }
  Future<Vendor> createVendor(Vendor vendor) async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('➕ Creating vendor: ${vendor.name}');

      // Build request body
      final Map<String, dynamic> requestBody = {
        'name': vendor.name,
        if (vendor.companyName != null) 'companyName': vendor.companyName,
        'type': vendor.type.name,
        if (vendor.email != null) 'email': vendor.email,
        if (vendor.phone != null) 'phone': vendor.phone,
        if (vendor.taxNumber != null) 'taxNumber': vendor.taxNumber,
        if (vendor.commercialRegistration != null)
          'commercialRegistration': vendor.commercialRegistration,
        if (vendor.contactPerson != null) 'contactPerson': vendor.contactPerson,
        if (vendor.bankAccount != null) 'bankAccount': vendor.bankAccount,
        if (vendor.address != null) 'address': vendor.address,
        if (vendor.notes != null) 'notes': vendor.notes,
      };

      // Add company ID for business mode
      if (currentAppMode == AppMode.business && companyId != null) {
        requestBody['companyId'] = companyId;
      }

      debugPrint('📤 POST /api/vendors');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/vendors',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract vendor from nested "vendor" object or direct object
        final Map<String, dynamic> vendorJson;
        if (responseData.containsKey('vendor') &&
            responseData['vendor'] is Map) {
          vendorJson = responseData['vendor'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          vendorJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing vendor object');
        }

        final newVendor = Vendor.fromApiJson(vendorJson);

        // Clear cache to force fresh reload
        clearCache();

        debugPrint('✅ Vendor created successfully: ${newVendor.id}');
        return newVendor;
      }

      throw ServerException(
        'Failed to create vendor',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating vendor: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create vendor: $e');
    }
  }

  /// Get all vendors from API
  /// GET /api/vendors
  Future<List<Vendor>> getAllVendors() async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint(
        '🔍 getAllVendors - Mode: $currentAppMode, Company: $companyId',
      );

      // Build query parameters based on app mode
      final Map<String, dynamic> queryParams = {};

      if (currentAppMode == AppMode.business && companyId != null) {
        queryParams['companyId'] = companyId;
      }

      final response = await _apiService.get(
        '/api/vendors',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> data =
            responseData['vendors'] ?? responseData['data'] ?? [];

        final vendors =
            data
                .map((json) => Vendor.fromApiJson(json as Map<String, dynamic>))
                .toList();

        // Cache the vendors
        _cachedVendors = vendors;

        debugPrint('✅ Loaded ${vendors.length} vendors from API');
        return vendors;
      }

      throw ServerException(
        'Failed to load vendors',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading vendors: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading vendors: $e');
    }
  }

  /// Get filtered vendors with pagination
  /// GET /api/vendors?page=1&limit=20&search=...&status=active&type=supplier&sort=totalSpent
  Future<Map<String, dynamic>> getFilteredVendors({
    int page = 1,
    int limit = 20,
    String? search,
    VendorStatus? status,
    VendorType? type,
    String? sort,
  }) async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('🔍 getFilteredVendors - Page: $page, Limit: $limit');

      // Build query parameters
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null) {
        queryParams['status'] = status.name;
      }
      if (type != null) {
        queryParams['type'] = type.name;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      if (currentAppMode == AppMode.business && companyId != null) {
        queryParams['companyId'] = companyId;
      }

      final response = await _apiService.get(
        '/api/vendors',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> vendorsData =
            responseData['vendors'] ?? responseData['data'] ?? [];
        final paginationData =
            responseData['pagination'] as Map<String, dynamic>?;

        final vendors =
            vendorsData
                .map((json) => Vendor.fromApiJson(json as Map<String, dynamic>))
                .toList();

        debugPrint('✅ Loaded ${vendors.length} filtered vendors from API');

        return {
          'vendors': vendors,
          'pagination':
              paginationData ??
              {'current': page, 'pages': 1, 'total': vendors.length},
        };
      }

      throw ServerException(
        'Failed to load filtered vendors',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading filtered vendors: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading filtered vendors: $e');
    }
  }

  /// Get top 10 vendors
  /// GET /api/vendors?top10
  Future<List<Vendor>> getTop10Vendors() async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('🔍 getTop10Vendors');

      // Build query parameters
      final Map<String, dynamic> queryParams = {'top10': 'true'};

      if (currentAppMode == AppMode.business && companyId != null) {
        queryParams['companyId'] = companyId;
      }

      final response = await _apiService.get(
        '/api/vendors',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final List<dynamic> data =
            responseData['vendors'] ?? responseData['data'] ?? [];

        final vendors =
            data
                .map((json) => Vendor.fromApiJson(json as Map<String, dynamic>))
                .toList();

        debugPrint('✅ Loaded ${vendors.length} top vendors from API');
        return vendors;
      }

      throw ServerException(
        'Failed to load top vendors',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading top vendors: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading top vendors: $e');
    }
  }

  /// Get a single vendor by ID
  /// GET /api/vendors/:id
  Future<Vendor?> getVendorById(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        debugPrint('⚠️ Empty vendorId - skipping fetch');
        return null;
      }

      // Try from cache first
      if (_cachedVendors != null) {
        try {
          return _cachedVendors!.firstWhere((v) => v.id == vendorId);
        } catch (_) {
          // Not in cache, fetch from API
        }
      }

      final response = await _apiService.get('/api/vendors/$vendorId');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final vendorData = responseData['vendor'] ?? responseData;

        return Vendor.fromApiJson(vendorData as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching vendor: $e');
      return null;
    }
  }

  /// Update an existing vendor
  /// PUT /api/vendors/:id
  Future<Vendor> updateVendor(Vendor vendor) async {
    try {
      if (vendor.id.isEmpty) {
        throw ValidationException('Vendor ID cannot be empty');
      }

      debugPrint('🔄 Updating vendor: ${vendor.id}');

      // Build update data (only include fields that should be updated)
      final Map<String, dynamic> updateData = {
        if (vendor.name.isNotEmpty) 'name': vendor.name,
        if (vendor.companyName != null) 'companyName': vendor.companyName,
        'type': vendor.type.name,
        'status': vendor.status.name,
        if (vendor.email != null) 'email': vendor.email,
        if (vendor.phone != null) 'phone': vendor.phone,
        if (vendor.address != null) 'address': vendor.address,
        if (vendor.taxNumber != null) 'taxNumber': vendor.taxNumber,
        if (vendor.commercialRegistration != null)
          'commercialRegistration': vendor.commercialRegistration,
        if (vendor.contactPerson != null) 'contactPerson': vendor.contactPerson,
        if (vendor.bankAccount != null) 'bankAccount': vendor.bankAccount,
        if (vendor.notes != null) 'notes': vendor.notes,
      };

      final response = await _apiService.put(
        '/api/vendors/${vendor.id}',
        data: updateData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final vendorData = responseData['vendor'] ?? responseData;

        final updatedVendor = Vendor.fromApiJson(
          vendorData as Map<String, dynamic>,
        );

        // Update cache
        if (_cachedVendors != null) {
          final index = _cachedVendors!.indexWhere((v) => v.id == vendor.id);
          if (index != -1) {
            _cachedVendors![index] = updatedVendor;
          }
        }

        debugPrint('✅ Vendor updated: ${updatedVendor.id}');
        return updatedVendor;
      }

      throw ServerException(
        'Failed to update vendor',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating vendor: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ValidationException) {
        rethrow;
      }
      throw ServerException('Error updating vendor: $e');
    }
  }

  /// Delete a vendor
  /// DELETE /api/vendors/:id
  Future<void> deleteVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        debugPrint('⚠️ Empty vendorId - skipping delete');
        return;
      }

      debugPrint('🗑️ Deleting vendor: $vendorId');

      final response = await _apiService.delete('/api/vendors/$vendorId');

      debugPrint('📥 Delete response status: ${response.statusCode}');
      debugPrint('📥 Delete response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear cache to force reload
        clearCache();

        debugPrint('✅ Vendor deleted successfully: $vendorId');
        return;
      }

      throw ServerException(
        'Failed to delete vendor',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting vendor: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error deleting vendor: $e');
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Get active vendors only
  Future<List<Vendor>> getActiveVendors() async {
    final vendors = await getAllVendors();
    return vendors.where((vendor) => vendor.isActive).toList();
  }

  /// Get vendors by type
  Future<List<Vendor>> getVendorsByType(VendorType type) async {
    final vendors = await getAllVendors();
    return vendors.where((vendor) => vendor.type == type).toList();
  }

  /// Search vendors (client-side filtering for backward compatibility)
  /// Note: Use getFilteredVendors with search parameter for server-side search
  Future<List<Vendor>> searchVendors(String searchTerm) async {
    final vendors = await getAllVendors();
    final lowerSearchTerm = searchTerm.toLowerCase();

    return vendors.where((vendor) {
      return vendor.name.toLowerCase().contains(lowerSearchTerm) ||
          (vendor.companyName?.toLowerCase().contains(lowerSearchTerm) ??
              false) ||
          (vendor.email?.toLowerCase().contains(lowerSearchTerm) ?? false) ||
          (vendor.phone?.contains(searchTerm) ?? false) ||
          (vendor.notes?.toLowerCase().contains(lowerSearchTerm) ?? false);
    }).toList();
  }

  /// Calculate vendor statistics (client-side calculation)
  /// Note: This aggregates from all vendors. For server-side stats, implement a dedicated endpoint
  Future<Map<String, dynamic>> getVendorsStatistics() async {
    try {
      final vendors = await getAllVendors();

      int totalVendors = vendors.length;
      int activeVendors = vendors.where((v) => v.isActive).length;

      double totalAmount = vendors.fold(
        0.0,
        (total, v) => total + v.totalSpent,
      );
      int totalTransactions = vendors.fold(
        0,
        (total, v) => total + v.transactionCount,
      );

      // Top vendors by total spent
      final sortedVendors = List<Vendor>.from(vendors)
        ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      final topVendors = sortedVendors.take(5).toList();

      return {
        'totalVendors': totalVendors,
        'activeVendors': activeVendors,
        'totalAmount': totalAmount,
        'totalTransactions': totalTransactions,
        'topVendors': topVendors,
      };
    } catch (e) {
      debugPrint('❌ Error calculating vendor statistics: $e');
      return {};
    }
  }
}
