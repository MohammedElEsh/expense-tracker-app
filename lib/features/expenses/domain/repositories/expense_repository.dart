import 'dart:io';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_statistics.dart';

// =============================================================================
// EXPENSE REPOSITORY - Clean Architecture Domain Layer
// =============================================================================

/// Abstract repository interface for expense operations.
///
/// Defines the contract that any expense data source implementation
/// must fulfill. This allows the domain/presentation layers to remain
/// independent of the concrete data source (REST API, local DB, etc.).
abstract class ExpenseRepository {
  // ===========================================================================
  // CRUD OPERATIONS
  // ===========================================================================

  /// Get all expenses with optional filters.
  ///
  /// Supports filtering by date range, [category], [accountId], [projectId],
  /// and pagination via [page] and [limit].
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? accountId,
    String? projectId,
    int? page,
    int? limit,
  });

  /// Get a single expense by its [expenseId].
  Future<Expense> getExpenseById(String expenseId);

  /// Create a new manual expense.
  ///
  /// Returns the created [Expense] with server-assigned fields.
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
  });

  /// Update an existing expense by [expenseId].
  ///
  /// Only the provided non-null fields will be updated.
  /// Returns the updated [Expense].
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
  });

  /// Delete an expense by its [expenseId].
  Future<void> deleteExpense(String expenseId);

  // ===========================================================================
  // OCR / RECEIPT SCANNING
  // ===========================================================================

  /// Scan a receipt image and create an expense from OCR results.
  ///
  /// Takes the [receiptImage] file and the [accountId] to associate
  /// the expense with. An optional [category] can be provided.
  /// Returns the created [Expense].
  Future<Expense> scanReceipt({
    required File receiptImage,
    required String accountId,
    String? category,
  });

  // ===========================================================================
  // STATISTICS & SUMMARIES
  // ===========================================================================

  /// Get expense statistics for the given date range.
  Future<ExpenseStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get monthly summary data.
  Future<List<MonthlySummary>> getMonthlySummary({int? year, int? month});

  /// Get category-wise spending summary.
  Future<List<CategorySummary>> getCategorySummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get account-wise spending summary.
  Future<List<AccountSummary>> getAccountsSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get expense timeline entries.
  Future<List<TimelineEntry>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  /// Clear cached expense data to force a fresh reload.
  void clearCache();
}
