// Add Expense - Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/add_expense_state.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/constants/category_constants.dart'
    show CategoryType;

class AddExpenseCubit extends Cubit<AddExpenseState> {
  final AppMode appMode;
  final Expense? expenseToEdit;

  AddExpenseCubit({
    DateTime? initialDate,
    required this.appMode,
    this.expenseToEdit,
  }) : super(
         AddExpenseState(
           date: initialDate ?? expenseToEdit?.date ?? DateTime.now(),
           amount: expenseToEdit?.amount ?? 0.0,
           category:
               expenseToEdit?.category ??
               Categories.getDefaultCategoryForType(
                 appMode == AppMode.business,
                 CategoryType.expense,
               ),
           customCategory: expenseToEdit?.customCategory,
           accountId: expenseToEdit?.accountId,
           notes: expenseToEdit?.notes ?? '',
           projectId: expenseToEdit?.projectId,
           department: expenseToEdit?.department,
           invoiceNumber: expenseToEdit?.invoiceNumber,
           vendorName: expenseToEdit?.vendorName,
           employeeId: expenseToEdit?.employeeId,
         ),
       );

  void changeAmount(double amount) {
    emit(state.copyWith(amount: amount));
  }

  void changeCategory(String category) {
    // Clear customCategory if category is changed away from "أخرى"
    emit(
      state.copyWith(
        category: category,
        clearCustomCategory: category != 'أخرى',
      ),
    );
  }

  void changeCustomCategory(String customCategory) {
    emit(state.copyWith(customCategory: customCategory));
  }

  void changeDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void changeAccount(String? accountId) {
    emit(state.copyWith(accountId: accountId));
  }

  void changeNotes(String notes) {
    emit(state.copyWith(notes: notes));
  }

  void changeProject(String? projectId) {
    emit(state.copyWith(projectId: projectId));
  }

  void changeEmployee(String? employeeId) {
    emit(state.copyWith(employeeId: employeeId));
  }

  void changeDepartment(String department) {
    emit(state.copyWith(department: department));
  }

  void changeInvoiceNumber(String invoiceNumber) {
    emit(state.copyWith(invoiceNumber: invoiceNumber));
  }

  void changeVendor(String vendorName) {
    emit(state.copyWith(vendorName: vendorName));
  }

  Future<void> loadBusinessData() async {
    if (appMode != AppMode.business) {
      emit(state.copyWith(isLoadingBusinessData: false));
      return;
    }

    try {
      emit(state.copyWith(isLoadingBusinessData: true));

      // Load all projects and filter out cancelled/completed
      final projectsResponse = await serviceLocator.projectService
          .getAllProjects(forceRefresh: false);
      final projects =
          projectsResponse.projects
              .where(
                (p) =>
                    p.status != ProjectStatus.cancelled &&
                    p.status != ProjectStatus.completed,
              )
              .toList();

      // Load vendors
      final vendorService = serviceLocator.vendorService;
      final vendors = await vendorService.getAllVendors();
      final vendorNames = vendors.map((v) => v.name).toList();

      emit(
        state.copyWith(
          availableProjects: projects,
          availableVendors: vendorNames,
          isLoadingBusinessData: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error loading business data: $error');
      emit(
        state.copyWith(isLoadingBusinessData: false, error: error.toString()),
      );
    }
  }

  Future<void> saveExpense({String? expenseIdToEdit}) async {
    // Validate form inputs
    if (!state.isValid) {
      String errorMessage = 'Please fill all required fields';
      if (state.amount <= 0) {
        errorMessage = 'Amount must be greater than 0';
      } else if (state.accountId == null || state.accountId!.isEmpty) {
        errorMessage = 'Please select an account';
      } else if (state.category.isEmpty) {
        errorMessage = 'Please select a category';
      } else if (state.category == 'أخرى' &&
          (state.customCategory == null ||
              state.customCategory!.trim().isEmpty)) {
        errorMessage = 'Please enter a custom category name';
      }
      emit(state.copyWith(error: errorMessage));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true, clearError: true));

      final expenseApiService = serviceLocator.expenseApiService;

      if (expenseIdToEdit != null && expenseIdToEdit.isNotEmpty) {
        // Update existing expense - PUT /api/expenses/:id (NEVER use POST for updates)
        debugPrint('✏️ Updating expense: $expenseIdToEdit');
        debugPrint('   Account: ${state.accountId}');
        debugPrint('   Amount: ${state.amount}');
        debugPrint('   Category: ${state.category}');
        debugPrint('   Date: ${state.date}');

        final updatedExpense = await expenseApiService.updateExpense(
          expenseIdToEdit,
          accountId:
              state.accountId?.isNotEmpty == true ? state.accountId : null,
          amount: state.amount > 0 ? state.amount : null,
          category: state.category.isNotEmpty ? state.category : null,
          customCategory:
              state.category == 'أخرى' &&
                      state.customCategory?.isNotEmpty == true
                  ? state.customCategory
                  : null,
          date: state.date,
          vendorName:
              state.vendorName?.isNotEmpty == true ? state.vendorName : null,
          invoiceNumber:
              state.invoiceNumber?.isNotEmpty == true
                  ? state.invoiceNumber
                  : null,
          notes: state.notes.isNotEmpty ? state.notes : null,
          projectId:
              state.projectId?.isNotEmpty == true ? state.projectId : null,
          employeeId:
              state.employeeId?.isNotEmpty == true ? state.employeeId : null,
        );

        debugPrint('✅ Expense updated successfully: ${updatedExpense.id}');
      } else {
        // Create new expense - POST /api/expenses
        debugPrint('➕ Creating new expense');
        debugPrint('   Account: ${state.accountId}');
        debugPrint('   Amount: ${state.amount}');
        debugPrint('   Category: ${state.category}');
        debugPrint('   Date: ${state.date}');

        final createdExpense = await expenseApiService.createExpense(
          accountId: state.accountId!,
          amount: state.amount,
          category: state.category,
          customCategory:
              state.category == 'أخرى' &&
                      state.customCategory?.isNotEmpty == true
                  ? state.customCategory
                  : null,
          date: state.date,
          vendorName:
              state.vendorName?.isNotEmpty == true ? state.vendorName : null,
          invoiceNumber:
              state.invoiceNumber?.isNotEmpty == true
                  ? state.invoiceNumber
                  : null,
          notes: state.notes.isNotEmpty ? state.notes : null,
          projectId:
              state.projectId?.isNotEmpty == true ? state.projectId : null,
          employeeId:
              state.employeeId?.isNotEmpty == true ? state.employeeId : null,
        );

        debugPrint('✅ Expense created successfully: ${createdExpense.id}');
      }

      emit(state.copyWith(isSaving: false, saveSuccess: true));
    } catch (error) {
      debugPrint('❌ Error creating expense: $error');

      // Handle API errors gracefully with user-friendly messages
      String errorMessage = 'Failed to create expense';
      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('ValidationException: ', '');
      } else if (error.toString().contains('ServerException')) {
        final statusMatch = RegExp(
          r'statusCode: (\d+)',
        ).firstMatch(error.toString());
        if (statusMatch != null) {
          final statusCode = int.parse(statusMatch.group(1)!);
          if (statusCode == 400) {
            errorMessage = 'Invalid expense data. Please check your inputs.';
          } else if (statusCode == 401) {
            errorMessage = 'Unauthorized. Please log in again.';
          } else if (statusCode == 403) {
            errorMessage = 'You do not have permission to create expenses.';
          } else if (statusCode >= 500) {
            errorMessage = 'Server error. Please try again later.';
          } else {
            errorMessage = 'Failed to create expense. Please try again.';
          }
        }
      } else {
        errorMessage = error.toString().replaceAll('Exception: ', '');
        if (errorMessage.length > 100) {
          errorMessage = 'Failed to create expense. Please try again.';
        }
      }

      emit(state.copyWith(isSaving: false, error: errorMessage));
    }
  }
}
