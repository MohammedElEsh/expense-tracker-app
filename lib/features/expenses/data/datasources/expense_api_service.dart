import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_statistics.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:dio/dio.dart';

// =============================================================================
// EXPENSE API SERVICE - Clean Architecture Remote Data Source
// =============================================================================

/// Remote data source for expenses using REST API
/// Uses core services: ApiService
/// No Firebase dependencies - pure REST API implementation
class ExpenseApiService {
  final ApiService _apiService;

  ExpenseApiService({required ApiService apiService})
    : _apiService = apiService;

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached expenses (for future use)
  void clearCache() {
    debugPrint('🗑️ Expense cache cleared');
  }

  // ===========================================================================
  // API METHODS - CRUD OPERATIONS
  // ===========================================================================

  /// Get all expenses
  /// GET /api/expenses
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? accountId,
    String? projectId,
    int? page,
    int? limit,
  }) async {
    try {
      final currentAppMode = SettingsService.appMode;
      final companyId = SettingsService.companyId;

      debugPrint('🔍 getExpenses - Mode: $currentAppMode, Company: $companyId');

      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (accountId != null && accountId.isNotEmpty) {
        queryParams['accountId'] = accountId;
      }
      if (projectId != null && projectId.isNotEmpty) {
        queryParams['projectId'] = projectId;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiService.get(
        '/api/expenses',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('📦 ExpenseApiService - Raw API response data type: ${data.runtimeType}');
        debugPrint(
          '📦 ExpenseApiService - Response keys: ${data is Map ? data.keys.toList() : 'N/A'}',
        );

        final List<dynamic> expensesList =
            data['expenses'] ?? data['data'] ?? [];
        
        debugPrint(
          '📦 ExpenseApiService - Raw expenses list length: ${expensesList.length}',
        );

        if (expensesList.isEmpty) {
          debugPrint('⚠️ ExpenseApiService - API returned empty expenses list');
          debugPrint('   Response data: $data');
        } else {
          debugPrint(
            '📦 ExpenseApiService - First raw expense: ${expensesList.first}',
          );
        }

        // Parse expenses with error handling
        final expenses = <Expense>[];
        for (int i = 0; i < expensesList.length; i++) {
          try {
            final expenseJson = expensesList[i] as Map<String, dynamic>;
            final expense = Expense.fromApiJson(expenseJson);
            expenses.add(expense);
          } catch (e, stackTrace) {
            debugPrint(
              '❌ ExpenseApiService - Error parsing expense at index $i: $e',
            );
            debugPrint('   Expense JSON: ${expensesList[i]}');
            debugPrint('   Stack trace: $stackTrace');
            // Continue parsing other expenses even if one fails
          }
        }

        debugPrint('✅ ExpenseApiService - Successfully parsed ${expenses.length}/${expensesList.length} expenses');
        debugPrint(
          '   Role-based filtering handled by backend via auth token',
        );
        return expenses;
      }

      // Handle specific error codes
      if (response.statusCode == 403) {
        throw ForbiddenException(
          'You do not have permission to view expenses',
        );
      }

      throw ServerException(
        'Failed to load expenses',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading expenses: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is ForbiddenException) {
        rethrow;
      }
      throw ServerException('Error loading expenses: $e');
    }
  }

  /// Get expense by ID
  /// GET /api/expenses/:id
  Future<Expense> getExpenseById(String expenseId) async {
    try {
      final response = await _apiService.get('/api/expenses/$expenseId');

      if (response.statusCode == 200) {
        final data = response.data;
        final expenseJson = data['expense'] ?? data['data'] ?? data;
        return Expense.fromApiJson(expenseJson as Map<String, dynamic>);
      }

      throw ServerException(
        'Failed to load expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading expense: $e');
    }
  }

  /// Create manual expense
  /// POST /api/expenses
  Future<Expense> createExpense({
    required String accountId,
    required double amount,
    required String category,
    String? customCategory,
    required DateTime date,
    String? vendorName,
    String? invoiceNumber,
    String? notes,
    String? projectId,
    String? employeeId,
  }) async {
    try {
      final requestBody = {
        'accountId': accountId,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
        if (customCategory != null && customCategory.isNotEmpty)
          'customCategory': customCategory,
        if (vendorName != null && vendorName.isNotEmpty)
          'vendorName': vendorName,
        if (invoiceNumber != null && invoiceNumber.isNotEmpty)
          'invoiceNumber': invoiceNumber,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
        if (employeeId != null && employeeId.isNotEmpty)
          'employeeId': employeeId,
      };

      debugPrint('💰 Creating expense: $requestBody');

      final response = await _apiService.post(
        '/api/expenses',
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final expenseJson = data['expense'] ?? data['data'] ?? data;
        final expense = Expense.fromApiJson(
          expenseJson as Map<String, dynamic>,
        );

        debugPrint('✅ Expense created successfully: ${expense.id}');
        return expense;
      }

      throw ServerException(
        'Failed to create expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error creating expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error creating expense: $e');
    }
  }

  /// Update expense
  /// PUT /api/expenses/:id
  Future<Expense> updateExpense(
    String expenseId, {
    String? accountId,
    double? amount,
    String? category,
    String? customCategory,
    DateTime? date,
    String? vendorName,
    String? invoiceNumber,
    String? notes,
    String? projectId,
    String? employeeId,
  }) async {
    try {
      final requestBody = <String, dynamic>{};

      if (accountId != null) requestBody['accountId'] = accountId;
      if (amount != null) requestBody['amount'] = amount;
      if (category != null) requestBody['category'] = category;
      if (customCategory != null) requestBody['customCategory'] = customCategory;
      if (date != null) {
        requestBody['date'] = date.toIso8601String().split('T')[0];
      }
      if (vendorName != null) requestBody['vendorName'] = vendorName;
      if (invoiceNumber != null) requestBody['invoiceNumber'] = invoiceNumber;
      if (notes != null) requestBody['notes'] = notes;
      if (projectId != null) requestBody['projectId'] = projectId;
      if (employeeId != null) requestBody['employeeId'] = employeeId;

      debugPrint('✏️ Updating expense $expenseId: $requestBody');

      final response = await _apiService.put(
        '/api/expenses/$expenseId',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final expenseJson = data['expense'] ?? data['data'] ?? data;
        final expense = Expense.fromApiJson(
          expenseJson as Map<String, dynamic>,
        );

        debugPrint('✅ Expense updated successfully: ${expense.id}');
        return expense;
      }

      throw ServerException(
        'Failed to update expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error updating expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error updating expense: $e');
    }
  }

  /// Delete expense
  /// DELETE /api/expenses/:id
  Future<void> deleteExpense(String expenseId) async {
    try {
      debugPrint('🗑️ Deleting expense: $expenseId');

      final response = await _apiService.delete('/api/expenses/$expenseId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Expense deleted successfully');
        return;
      }

      throw ServerException(
        'Failed to delete expense',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error deleting expense: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error deleting expense: $e');
    }
  }

  /// Scan receipt (OCR upload)
  /// POST /api/expenses/scan-receipt
  /// Sends form-data: receipt (file), accountId (required), category (optional)
  Future<Expense> scanReceipt({
    required File receiptImage,
    required String accountId,
    String? category,
  }) async {
    try {
      // Validate inputs
      if (!await receiptImage.exists()) {
        throw ValidationException('Receipt image file does not exist');
      }

      if (accountId.isEmpty) {
        throw ValidationException('Account ID is required');
      }

      debugPrint('📸 Scanning receipt...');
      debugPrint('   Account ID: $accountId');
      debugPrint('   Category: ${category ?? 'not provided'}');
      debugPrint('   Image path: ${receiptImage.path}');

      // Create form data with required fields
      final formData = FormData.fromMap({
        'receipt': await MultipartFile.fromFile(
          receiptImage.path,
          filename: receiptImage.path.split('/').last,
        ),
        'accountId': accountId, // Required field
        if (category != null && category.isNotEmpty) 'category': category,
      });

      final response = await _apiService.post(
        '/api/expenses/scan-receipt',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final expenseJson = data['expense'] ?? data['data'] ?? data;
        
        if (expenseJson == null) {
          throw ServerException(
            'Invalid response format from server',
            statusCode: response.statusCode,
          );
        }

        final expense = Expense.fromApiJson(
          expenseJson as Map<String, dynamic>,
        );

        debugPrint('✅ Receipt scanned successfully: ${expense.id}');
        debugPrint('   Amount: ${expense.amount}');
        debugPrint('   Category: ${expense.category}');
        debugPrint('   Vendor: ${expense.vendorName ?? 'N/A'}');
        
        return expense;
      }

      // Handle specific error status codes
      final statusCode = response.statusCode;
      String errorMessage = 'Failed to scan receipt';
      
      if (statusCode == 400) {
        errorMessage = 'Invalid image file or missing required fields';
      } else if (statusCode == 401) {
        throw UnauthorizedException('Please log in again');
      } else if (statusCode == 403) {
        throw ForbiddenException('You do not have permission to scan receipts');
      } else if (statusCode == 404) {
        errorMessage = 'Account not found';
      } else if (statusCode != null && statusCode >= 500) {
        errorMessage = 'Server error. Please try again later.';
      }

      throw ServerException(
        errorMessage,
        statusCode: statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error scanning receipt: $e');
      if (e is ServerException || 
          e is NetworkException || 
          e is ValidationException ||
          e is UnauthorizedException ||
          e is ForbiddenException) {
        rethrow;
      }
      throw ServerException('Error scanning receipt: $e');
    }
  }

  // ===========================================================================
  // STATISTICS & SUMMARIES
  // ===========================================================================

  /// Get expenses statistics
  /// GET /api/expenses/statistics
  Future<ExpenseStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        '/api/expenses/statistics',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return ExpenseStatistics.fromJson(data as Map<String, dynamic>);
      }

      throw ServerException(
        'Failed to load statistics',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading statistics: $e');
    }
  }

  /// Get monthly summary
  /// GET /api/expenses/summary/monthly
  Future<List<MonthlySummary>> getMonthlySummary({
    int? year,
    int? month,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _apiService.get(
        '/api/expenses/summary/monthly',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> summaries = data['summaries'] ?? data['data'] ?? [];
        return summaries
            .map(
              (json) => MonthlySummary.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw ServerException(
        'Failed to load monthly summary',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading monthly summary: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading monthly summary: $e');
    }
  }

  /// Get category summary
  /// GET /api/expenses/summary/category
  Future<List<CategorySummary>> getCategorySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        '/api/expenses/summary/category',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> summaries = data['summaries'] ?? data['data'] ?? [];
        return summaries
            .map(
              (json) => CategorySummary.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw ServerException(
        'Failed to load category summary',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading category summary: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading category summary: $e');
    }
  }

  /// Get accounts summary
  /// GET /api/expenses/summary/accounts
  Future<List<AccountSummary>> getAccountsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get(
        '/api/expenses/summary/accounts',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> summaries = data['summaries'] ?? data['data'] ?? [];
        return summaries
            .map(
              (json) => AccountSummary.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      throw ServerException(
        'Failed to load accounts summary',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading accounts summary: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading accounts summary: $e');
    }
  }

  /// Get timeline
  /// GET /api/expenses/timeline
  Future<List<TimelineEntry>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _apiService.get(
        '/api/expenses/timeline',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> timeline = data['timeline'] ?? data['data'] ?? [];
        return timeline
            .map((json) => TimelineEntry.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        'Failed to load timeline',
        statusCode: response.statusCode,
      );
    } catch (e) {
      debugPrint('❌ Error loading timeline: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Error loading timeline: $e');
    }
  }
}
