import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';

/// Remote data source for recurring expenses. Uses ApiService (company scoped via auth).
class RecurringExpenseRemoteDataSource {
  final ApiService _apiService;

  List<RecurringExpense>? _cachedExpenses;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  RecurringExpenseRemoteDataSource({
    required ApiService apiService,
  }) : _apiService = apiService;

  bool get _isCacheValid {
    if (_cachedExpenses == null || _cacheTime == null) return false;
    return DateTime.now().difference(_cacheTime!) < _cacheDuration;
  }

  void clearCache() {
    _cachedExpenses = null;
    _cacheTime = null;
    debugPrint('🗑️ Recurring expenses cache cleared');
  }

  Future<List<RecurringExpense>> getRecurringExpenses({
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && _isCacheValid) {
        return _cachedExpenses!;
      }

      final response = await _apiService.get('/api/recurring-expenses');

      if (response.statusCode == 200) {
        final responseData = response.data;
        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map) {
          data = responseData['expenses'] ?? responseData['data'] ?? [];
        } else {
          data = [];
        }
        final expenses = data
            .map((json) => RecurringExpense.fromJson(json as Map<String, dynamic>))
            .toList();

        _cachedExpenses = expenses;
        _cacheTime = DateTime.now();
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

  Future<RecurringExpense?> getRecurringExpenseById(String id) async {
    final expenses = await getRecurringExpenses(forceRefresh: false);
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<RecurringExpense> createRecurringExpense(RecurringExpense expense) async {
    try {
      final requestBody = expense.toJson();
      final response = await _apiService.post(
        '/api/recurring-expenses',
        data: requestBody,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final expenseJson = _extractExpenseJson(responseData);
        final newExpense = RecurringExpense.fromJson(expenseJson);
        clearCache();
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

  Future<RecurringExpense> updateRecurringExpense(RecurringExpense expense) async {
    try {
      final requestBody = expense.toJson();
      final response = await _apiService.put(
        '/api/recurring-expenses/${expense.id}',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        final expenseJson = _extractExpenseJson(responseData);
        if (expenseJson.isEmpty) {
          clearCache();
          final list = await getRecurringExpenses(forceRefresh: true);
          final updated = list.firstWhere(
            (e) => e.id == expense.id,
            orElse: () => throw ServerException('Expense not found after update'),
          );
          return updated;
        }
        final updatedExpense = RecurringExpense.fromJson(expenseJson);
        clearCache();
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

  Future<void> toggleRecurringExpense(String id, bool isActive) async {
    try {
      final response = await _apiService.put(
        '/api/recurring-expenses/$id',
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        clearCache();
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

  Future<void> deleteRecurringExpense(String id) async {
    try {
      final response = await _apiService.delete('/api/recurring-expenses/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        clearCache();
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

  Map<String, dynamic> _extractExpenseJson(Map<String, dynamic> responseData) {
    if (responseData.containsKey('recurring') && responseData['recurring'] is Map) {
      return responseData['recurring'] as Map<String, dynamic>;
    }
    if (responseData.containsKey('expense') && responseData['expense'] is Map) {
      return responseData['expense'] as Map<String, dynamic>;
    }
    if (responseData.containsKey('data') && responseData['data'] is Map) {
      return responseData['data'] as Map<String, dynamic>;
    }
    if (responseData.containsKey('_id')) {
      return responseData;
    }
    return {};
  }
}
