import 'dart:io';
import 'package:expense_tracker/features/expenses/data/datasources/expense_api_service.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/data/models/expense_statistics.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({required ExpenseApiService expenseApiService})
      : _service = expenseApiService;

  final ExpenseApiService _service;

  @override
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? accountId,
    String? projectId,
    int? page,
    int? limit,
  }) =>
      _service.getExpenses(
        startDate: startDate,
        endDate: endDate,
        category: category,
        accountId: accountId,
        projectId: projectId,
        page: page,
        limit: limit,
      );

  @override
  Future<Expense> getExpenseById(String expenseId) =>
      _service.getExpenseById(expenseId);

  @override
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
  }) =>
      _service.createExpense(
        accountId: accountId,
        amount: amount,
        category: category,
        customCategory: customCategory,
        date: date,
        vendorName: vendorName,
        invoiceNumber: invoiceNumber,
        notes: notes,
        projectId: projectId,
        employeeId: employeeId,
      );

  @override
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
  }) =>
      _service.updateExpense(
        expenseId,
        accountId: accountId,
        amount: amount,
        category: category,
        customCategory: customCategory,
        date: date,
        vendorName: vendorName,
        invoiceNumber: invoiceNumber,
        notes: notes,
        projectId: projectId,
        employeeId: employeeId,
      );

  @override
  Future<void> deleteExpense(String expenseId) =>
      _service.deleteExpense(expenseId);

  @override
  Future<Expense> scanReceipt({
    required File receiptImage,
    required String accountId,
    String? category,
  }) =>
      _service.scanReceipt(
        receiptImage: receiptImage,
        accountId: accountId,
        category: category,
      );

  @override
  Future<ExpenseStatistics> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _service.getStatistics(startDate: startDate, endDate: endDate);

  @override
  Future<List<MonthlySummary>> getMonthlySummary({int? year, int? month}) =>
      _service.getMonthlySummary(year: year, month: month);

  @override
  Future<List<CategorySummary>> getCategorySummary({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _service.getCategorySummary(startDate: startDate, endDate: endDate);

  @override
  Future<List<AccountSummary>> getAccountsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _service.getAccountsSummary(startDate: startDate, endDate: endDate);

  @override
  Future<List<TimelineEntry>> getTimeline({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) =>
      _service.getTimeline(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

  @override
  void clearCache() => _service.clearCache();
}
