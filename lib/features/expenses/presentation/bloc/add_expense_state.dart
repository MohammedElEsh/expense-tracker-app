// Add Expense - BLoC State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';

class AddExpenseState extends Equatable {
  final double amount;
  final String category;
  final String? customCategory; // فئة مخصصة عندما تكون category == "أخرى"
  final DateTime date;
  final String? accountId;
  final String notes;
  final String? projectId;
  final String? department;
  final String? invoiceNumber;
  final String? vendorName;
  final String? employeeId;

  // بيانات للعرض
  final List<Project> availableProjects;
  final List<String> availableVendors;

  // حالة التحميل
  final bool isLoadingBusinessData;
  final bool isSaving;
  final String? error;
  final bool saveSuccess;

  AddExpenseState({
    this.amount = 0.0,
    this.category = '', // Will be set based on app mode
    this.customCategory,
    DateTime? date,
    this.accountId,
    this.notes = '',
    this.projectId,
    this.department,
    this.invoiceNumber,
    this.vendorName,
    this.employeeId,
    this.availableProjects = const [],
    this.availableVendors = const [],
    this.isLoadingBusinessData = false,
    this.isSaving = false,
    this.error,
    this.saveSuccess = false,
  }) : date = date ?? DateTime.now();

  @override
  List<Object?> get props => [
    amount,
    category,
    customCategory,
    date,
    accountId,
    notes,
    projectId,
    department,
    invoiceNumber,
    vendorName,
    employeeId,
    availableProjects,
    availableVendors,
    isLoadingBusinessData,
    isSaving,
    error,
    saveSuccess,
  ];

  AddExpenseState copyWith({
    double? amount,
    String? category,
    String? customCategory,
    DateTime? date,
    String? accountId,
    String? notes,
    String? projectId,
    String? department,
    String? invoiceNumber,
    String? vendorName,
    String? employeeId,
    List<Project>? availableProjects,
    List<String>? availableVendors,
    bool? isLoadingBusinessData,
    bool? isSaving,
    String? error,
    bool? saveSuccess,
    bool clearError = false,
    bool clearAccountId = false,
    bool clearProjectId = false,
    bool clearCustomCategory = false,
  }) {
    return AddExpenseState(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      customCategory: clearCustomCategory ? null : (customCategory ?? this.customCategory),
      date: date ?? this.date,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      notes: notes ?? this.notes,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      department: department ?? this.department,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      vendorName: vendorName ?? this.vendorName,
      employeeId: employeeId ?? this.employeeId,
      availableProjects: availableProjects ?? this.availableProjects,
      availableVendors: availableVendors ?? this.availableVendors,
      isLoadingBusinessData:
          isLoadingBusinessData ?? this.isLoadingBusinessData,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  bool get isValid {
    // If category is "أخرى", customCategory is required
    if (category == 'أخرى') {
      return amount > 0 && 
             accountId != null && 
             accountId!.isNotEmpty &&
             customCategory != null &&
             customCategory!.trim().isNotEmpty;
    }
    return amount > 0 && accountId != null && accountId!.isNotEmpty;
  }
}
