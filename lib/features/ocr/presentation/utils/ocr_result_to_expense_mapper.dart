import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';

/// Maps OCR result + form context to Expense for preview/dialog (presentation only).
Expense mapOcrResultToExpense(
  OcrResultEntity result, {
  required String? accountId,
  required String? category,
  required AppMode appMode,
  String? photoPath,
}) {
  return Expense(
    id: 'ocr_${DateTime.now().millisecondsSinceEpoch}',
    amount: result.totalAmount,
    category: category?.isNotEmpty == true ? category! : 'أخرى',
    customCategory: null,
    notes: result.merchantName,
    date: result.date,
    accountId: accountId ?? '',
    appMode: appMode,
    photoPath: photoPath,
    vendorName: result.merchantName.isNotEmpty ? result.merchantName : null,
    projectId: null,
    department: null,
    invoiceNumber: null,
    employeeId: null,
    employeeName: null,
    displayCategory: null,
    createdAt: null,
    updatedAt: null,
  );
}
