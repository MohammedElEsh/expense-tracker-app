import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';

// =============================================================================
// RECURRING EXPENSE API SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Remote data source for recurring expenses using REST API
/// Uses core services: ApiService (Dio)
/// Endpoints:
/// - POST /api/recurring-expenses (create)
/// - GET /api/recurring-expenses (get all)
/// - PUT /api/recurring/{id} (update isActive)
/// - DELETE /api/recurring/{id} (delete)
class RecurringExpenseApiService {
  final ApiService _apiService;

  // Cache for recurring expenses
  List<RecurringExpense>? _cachedExpenses;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  RecurringExpenseApiService({required ApiService apiService})
    : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_cachedExpenses == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  /// Clear cached expenses
  void clearCache() {
    _cachedExpenses = null;
    _cacheTime = null;
    debugPrint('🗑️ Recurring expenses cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Load all recurring expenses from API
  /// GET /api/recurring-expenses
  ///
  /// Response format:
  /// {
  ///   "success": true,
  ///   "count": 1,
  ///   "expenses": [...]
  /// }
  Future<List<RecurringExpense>> loadRecurringExpenses({
    bool forceRefresh = false,
  }) async {
    try {
      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _isCacheValid) {
        debugPrint(
          '📦 Returning cached recurring expenses: ${_cachedExpenses!.length}',
        );
        return _cachedExpenses!;
      }

      debugPrint('🔍 Loading recurring expenses from API...');

      final response = await _apiService.get('/api/recurring-expenses');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle response format
        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = responseData['expenses'] ?? responseData['data'] ?? [];
        } else {
          data = [];
        }
        final expenses =
            data
                .map(
                  (json) =>
                      RecurringExpense.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        // Update cache
        _cachedExpenses = expenses;
        _cacheTime = DateTime.now();

        debugPrint('✅ Loaded ${expenses.length} recurring expenses');
        for (final expense in expenses) {
          debugPrint(
            '💰 Recurring: ${expense.notes} - ${expense.amount} (${expense.recurrenceType.displayName}) - Active: ${expense.isActive}',
          );
        }

        return expenses;
      }

      throw ServerException(
        'Failed to load recurring expenses',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading recurring expenses: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading recurring expenses: $e');
    }
  }

  /// Create a new recurring expense
  /// POST /api/recurring-expenses
  ///
  /// Request Body:
  /// {
  ///   "accountId": "...",
  ///   "amount": 499,
  ///   "category": "فواتير",
  ///   "notes": "اشتراك نتفلكس",
  ///   "recurrenceType": "monthly",
  ///   "dayOfMonth": 15
  /// }
  Future<RecurringExpense> createRecurringExpense(
    RecurringExpense expense,
  ) async {
    try {
      debugPrint('➕ Creating recurring expense: ${expense.notes}');

      final requestBody = expense.toJson();
      debugPrint('📤 POST /api/recurring-expenses');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.post(
        '/api/recurring-expenses',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract expense from response
        // API returns: { "success": true, "recurring": {...} }
        Map<String, dynamic> expenseJson;
        if (responseData.containsKey('recurring') &&
            responseData['recurring'] is Map) {
          expenseJson = responseData['recurring'] as Map<String, dynamic>;
        } else if (responseData.containsKey('expense') &&
            responseData['expense'] is Map) {
          expenseJson = responseData['expense'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          expenseJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          // Direct expense object
          expenseJson = responseData;
        } else {
          throw ServerException('Invalid API response: missing expense data');
        }

        final newExpense = RecurringExpense.fromJson(expenseJson);

        // Clear cache to force refresh
        clearCache();

        debugPrint('✅ Recurring expense created: ${newExpense.id}');
        return newExpense;
      }

      throw ServerException(
        'Failed to create recurring expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating recurring expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to create recurring expense: $e');
    }
  }

  /// Update recurring expense (full update)
  /// PUT /api/recurring/{id}
  ///
  /// Request Body: Full expense object
  Future<RecurringExpense> updateRecurringExpense(
    RecurringExpense expense,
  ) async {
    try {
      debugPrint('🔄 Updating recurring expense: ${expense.id}');

      final requestBody = expense.toJson();
      debugPrint('📤 PUT /api/recurring-expenses/${expense.id}');
      debugPrint('📤 Request body: $requestBody');

      final response = await _apiService.put(
        '/api/recurring-expenses/${expense.id}',
        data: requestBody,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract expense from response
        // API may return: { "success": true, "recurring": {...} }
        Map<String, dynamic> expenseJson;
        if (responseData.containsKey('recurring') &&
            responseData['recurring'] is Map) {
          expenseJson = responseData['recurring'] as Map<String, dynamic>;
        } else if (responseData.containsKey('expense') &&
            responseData['expense'] is Map) {
          expenseJson = responseData['expense'] as Map<String, dynamic>;
        } else if (responseData.containsKey('data') &&
            responseData['data'] is Map) {
          expenseJson = responseData['data'] as Map<String, dynamic>;
        } else if (responseData.containsKey('_id')) {
          expenseJson = responseData;
        } else {
          // If no expense in response, return updated version from cache
          clearCache();
          final expenses = await loadRecurringExpenses(forceRefresh: true);
          final updated = expenses.firstWhere(
            (e) => e.id == expense.id,
            orElse:
                () => throw ServerException('Expense not found after update'),
          );
          return updated;
        }

        final updatedExpense = RecurringExpense.fromJson(expenseJson);

        // Clear cache to force refresh
        clearCache();

        debugPrint('✅ Recurring expense updated: ${expense.id}');
        return updatedExpense;
      }

      throw ServerException(
        'Failed to update recurring expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating recurring expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to update recurring expense: $e');
    }
  }

  /// Toggle recurring expense active status
  /// PUT /api/recurring/{id} with only isActive field
  Future<void> toggleRecurringExpense(String id, bool isActive) async {
    try {
      debugPrint('🔄 Toggling recurring expense: $id, isActive: $isActive');

      final response = await _apiService.put(
        '/api/recurring-expenses/$id',
        data: {'isActive': isActive},
      );

      debugPrint('📥 Toggle response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Clear cache to force refresh
        clearCache();
        debugPrint('✅ Recurring expense toggled: $id');
        return;
      }

      throw ServerException(
        'Failed to toggle recurring expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error toggling recurring expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to toggle recurring expense: $e');
    }
  }

  /// Delete a recurring expense
  /// DELETE /api/recurring/{id}
  Future<void> deleteRecurringExpense(String id) async {
    try {
      debugPrint('🗑️ Deleting recurring expense: $id');

      final response = await _apiService.delete('/api/recurring-expenses/$id');

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear cache to force refresh
        clearCache();

        debugPrint('✅ Recurring expense deleted: $id');
        return;
      }

      throw ServerException(
        'Failed to delete recurring expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting recurring expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Failed to delete recurring expense: $e');
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  /// Get active recurring expenses only
  Future<List<RecurringExpense>> getActiveRecurringExpenses() async {
    final expenses = await loadRecurringExpenses();
    return expenses.where((e) => e.isActive).toList();
  }

  /// Get inactive recurring expenses only
  Future<List<RecurringExpense>> getInactiveRecurringExpenses() async {
    final expenses = await loadRecurringExpenses();
    return expenses.where((e) => !e.isActive).toList();
  }

  /// Calculate monthly recurring total
  Future<double> calculateMonthlyRecurringTotal() async {
    final expenses = await getActiveRecurringExpenses();
    double total = 0;

    for (final expense in expenses) {
      switch (expense.recurrenceType) {
        case RecurrenceType.daily:
          total += expense.amount * 30; // Approximate days in month
          break;
        case RecurrenceType.weekly:
          total += expense.amount * 4; // Approximate weeks in month
          break;
        case RecurrenceType.monthly:
          total += expense.amount;
          break;
        case RecurrenceType.yearly:
          total += expense.amount / 12;
          break;
      }
    }

    return total;
  }

  /// Get upcoming recurring expenses (due within next 7 days)
  Future<List<RecurringExpense>> getUpcomingRecurringExpenses() async {
    final expenses = await getActiveRecurringExpenses();
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return expenses.where((expense) {
      final nextDue = expense.nextDue ?? expense.calculateNextDue();
      return nextDue.isAfter(now) && nextDue.isBefore(weekFromNow);
    }).toList();
  }

  /// Get a single recurring expense by ID
  Future<RecurringExpense?> getRecurringExpense(String id) async {
    final expenses = await loadRecurringExpenses();
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
