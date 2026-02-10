import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';

// =============================================================================
// BUDGET SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Remote data source for budgets using REST API
/// Uses core services: ApiService
/// No Firebase dependencies - pure REST API implementation
class BudgetService {
  final ApiService _apiService;

  // Cache for budgets by month/year
  Map<String, List<Budget>>? _cachedBudgets;

  BudgetService({required ApiService apiService}) : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Get cache key for month/year
  String _getCacheKey(int year, int month) => '$year-$month';

  /// Clear cached budgets
  void clearCache() {
    _cachedBudgets = null;
    debugPrint('🗑️ Budget cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Load budgets for a specific month and year from API
  /// GET /api/budgets?month={month}&year={year}
  Future<List<Budget>> loadBudgets({
    required int month,
    required int year,
  }) async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint(
        '🔍 loadBudgets - Month: $month, Year: $year, Mode: $currentAppMode',
      );

      // Build query parameters
      final Map<String, dynamic> queryParams = {'month': month, 'year': year};

      // Add company ID for business mode
      if (currentAppMode == AppMode.business && companyId != null) {
        queryParams['companyId'] = companyId;
      }

      final response = await _apiService.get(
        '/api/budgets',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle different response formats
        List<dynamic> data;
        int responseMonth = month;
        int responseYear = year;

        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          // Response might be { success: true, month: 12, year: 2025, data: [...] }
          data = responseData['data'] ?? responseData['budgets'] ?? [];
          // Get month/year from top-level response (they may not be in individual items)
          responseMonth = responseData['month'] ?? month;
          responseYear = responseData['year'] ?? year;
        } else {
          data = [];
        }

        final budgets =
            data.map((json) {
              final budgetJson = json as Map<String, dynamic>;
              // If month/year not in budget object, use from top-level response
              if (budgetJson['month'] == null) {
                budgetJson['month'] = responseMonth;
              }
              if (budgetJson['year'] == null) {
                budgetJson['year'] = responseYear;
              }
              return Budget.fromJson(budgetJson);
            }).toList();

        // Cache the budgets
        _cachedBudgets ??= {};
        _cachedBudgets![_getCacheKey(year, month)] = budgets;

        debugPrint('✅ Loaded ${budgets.length} budgets for $month/$year');
        for (final budget in budgets) {
          debugPrint(
            '💰 Budget: ${budget.category} - Limit: ${budget.limit}, Spent: ${budget.spent}, Month: ${budget.month}, Year: ${budget.year}',
          );
        }

        return budgets;
      }

      throw ServerException(
        'Failed to load budgets',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading budgets: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading budgets: $e');
    }
  }

  /// Create or update a budget via API
  /// POST /api/budgets
  ///
  /// Request Body:
  /// {
  ///   "category": "طعام ومطاعم",
  ///   "limit": 3000,
  ///   "month": 12,
  ///   "year": 2025
  /// }
  ///
  /// Response: { "success": true, "message": "...", "data": { ... } }
  Future<Budget> createOrUpdateBudget({
    required String category,
    required double limit,
    required int month,
    required int year,
  }) async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('➕ Creating/Updating budget: $category for $month/$year');

      // Build request body
      final Map<String, dynamic> requestBody = {
        'category': category,
        'limit': limit,
        'month': month,
        'year': year,
      };

      // Add company ID for business mode
      if (currentAppMode == AppMode.business && companyId != null) {
        requestBody['companyId'] = companyId;
      }

      debugPrint('📤 POST /api/budgets');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/budgets',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract budget from response
        // Response format: { "success": true, "message": "...", "data": { ... } }
        final Map<String, dynamic> budgetJson;
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          budgetJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('budget') &&
            responseData['budget'] is Map) {
          budgetJson = responseData['budget'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          // Direct budget object (fallback)
          budgetJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing budget data');
        }

        final newBudget = Budget.fromJson(budgetJson);

        // Clear cache to force fresh reload
        clearCache();

        debugPrint('✅ Budget created/updated successfully: ${newBudget.id}');
        debugPrint(
          '✅ Category: ${newBudget.category}, Limit: ${newBudget.limit}',
        );
        return newBudget;
      }

      throw ServerException(
        'Failed to create/update budget',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating/updating budget: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create/update budget: $e');
    }
  }

  /// Save/Update a budget (convenience method that takes a Budget object)
  /// Uses createOrUpdateBudget internally
  // Future<Budget> saveBudget(Budget budget) async {
  //   return createOrUpdateBudget(
  //     category: budget.category,
  //     limit: budget.limit,
  //     month: budget.month,
  //     year: budget.year,
  //   );
  // }

  /// Delete a budget
  /// Note: This is a local operation since the API doesn't have a delete endpoint
  /// The budget will be effectively removed by setting limit to 0 or not showing
  /// budgets with 0 limit
  // Future<void> deleteBudget(String category, int year, int month) async {
  //   try {
  //     debugPrint('🗑️ Deleting budget: $category for $month/$year');
  //
  //     // Set limit to 0 to effectively delete the budget
  //     await createOrUpdateBudget(
  //       category: category,
  //       limit: 0,
  //       month: month,
  //       year: year,
  //     );
  //
  //     // Clear cache
  //     clearCache();
  //
  //     debugPrint('✅ Budget deleted (set to 0): $category');
  //   } catch (e) {
  //     debugPrint('❌ Error deleting budget: $e');
  //     if (e is ServerException || e is NetworkException) rethrow;
  //     throw ServerException('Error deleting budget: $e');
  //   }
  // }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Get all budgets (from cache if available)
  // Future<List<Budget>> getAllBudgets() async {
  //   // Return cached budgets if available
  //   if (_cachedBudgets != null && _cachedBudgets!.isNotEmpty) {
  //     final allBudgets = <Budget>[];
  //     for (final budgets in _cachedBudgets!.values) {
  //       allBudgets.addAll(budgets);
  //     }
  //     return allBudgets;
  //   }
  //
  //   // Otherwise, load current month budgets
  //   final now = DateTime.now();
  //   return loadBudgets(month: now.month, year: now.year);
  // }

  /// Get budgets for a specific month from cache or API
  // Future<Map<String, Budget>> getBudgetsForMonth(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //
  //   // Filter out budgets with 0 limit (deleted)
  //   final Map<String, Budget> budgetMap = {};
  //   for (var budget in budgets) {
  //     if (budget.limit > 0) {
  //       budgetMap[budget.category] = budget;
  //     }
  //   }
  //   return budgetMap;
  // }

  /// Get a specific budget for a category
  // Future<Budget?> getBudgetForCategory(
  //   String category,
  //   int year,
  //   int month,
  // ) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   try {
  //     return budgets.firstWhere((b) => b.category == category && b.limit > 0);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  /// Calculate total budget for a month
  // Future<double> getTotalBudget(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   double total = 0.0;
  //   for (final budget in budgets.where((b) => b.limit > 0)) {
  //     total += budget.limit;
  //   }
  //   return total;
  // }

  /// Calculate total spent for a month
  // Future<double> getTotalSpent(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   double total = 0.0;
  //   for (final budget in budgets.where((b) => b.limit > 0)) {
  //     total += budget.spent;
  //   }
  //   return total;
  // }

  /// Get over-budget categories
  // Future<List<Budget>> getOverBudgetCategories(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   return budgets.where((b) => b.isOverBudget && b.limit > 0).toList();
  // }

  /// Get near-limit categories (80%+ spent)
  // Future<List<Budget>> getNearLimitCategories(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   return budgets.where((b) => b.isNearLimit && b.limit > 0).toList();
  // }

  /// Check if user has any budgets for the month
  // Future<bool> hasBudgets(int year, int month) async {
  //   final budgets = await loadBudgets(month: month, year: year);
  //   return budgets.any((b) => b.limit > 0);
  // }
}
