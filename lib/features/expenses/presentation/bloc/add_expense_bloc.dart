// Add Expense - BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'add_expense_event.dart';
import 'add_expense_state.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/constants/category_constants.dart' show CategoryType;

class AddExpenseBloc extends Bloc<AddExpenseEvent, AddExpenseState> {
  final AppMode appMode;
  final Expense? expenseToEdit;

  AddExpenseBloc({
    DateTime? initialDate,
    required this.appMode,
    this.expenseToEdit,
  }) : super(
         AddExpenseState(
           date: initialDate ?? expenseToEdit?.date ?? DateTime.now(),
           amount: expenseToEdit?.amount ?? 0.0,
           category: expenseToEdit?.category ?? Categories.getDefaultCategoryForType(
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
       ) {
    on<ChangeAmountEvent>(_onChangeAmount);
    on<ChangeCategoryEvent>(_onChangeCategory);
    on<ChangeCustomCategoryEvent>(_onChangeCustomCategory);
    on<ChangeDateEvent>(_onChangeDate);
    on<ChangeAccountEvent>(_onChangeAccount);
    on<ChangeNotesEvent>(_onChangeNotes);
    on<LoadBusinessDataEvent>(_onLoadBusinessData);
    on<ChangeProjectEvent>(_onChangeProject);
    on<ChangeEmployeeEvent>(_onChangeEmployee);
    on<ChangeDepartmentEvent>(_onChangeDepartment);
    on<ChangeInvoiceNumberEvent>(_onChangeInvoiceNumber);
    on<ChangeVendorEvent>(_onChangeVendor);
    on<SaveExpenseEvent>(_onSaveExpense);
  }

  void _onChangeAmount(ChangeAmountEvent event, Emitter<AddExpenseState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onChangeCategory(
    ChangeCategoryEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    // Clear customCategory if category is changed away from "أخرى"
    emit(state.copyWith(
      category: event.category,
      clearCustomCategory: event.category != 'أخرى',
    ));
  }

  void _onChangeCustomCategory(
    ChangeCustomCategoryEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(customCategory: event.customCategory));
  }

  void _onChangeDate(ChangeDateEvent event, Emitter<AddExpenseState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onChangeAccount(
    ChangeAccountEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(accountId: event.accountId));
  }

  void _onChangeNotes(ChangeNotesEvent event, Emitter<AddExpenseState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onChangeProject(
    ChangeProjectEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(projectId: event.projectId));
  }

  void _onChangeEmployee(
    ChangeEmployeeEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(employeeId: event.employeeId));
  }

  void _onChangeDepartment(
    ChangeDepartmentEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(department: event.department));
  }

  void _onChangeInvoiceNumber(
    ChangeInvoiceNumberEvent event,
    Emitter<AddExpenseState> emit,
  ) {
    emit(state.copyWith(invoiceNumber: event.invoiceNumber));
  }

  void _onChangeVendor(ChangeVendorEvent event, Emitter<AddExpenseState> emit) {
    emit(state.copyWith(vendorName: event.vendorName));
  }

  Future<void> _onLoadBusinessData(
    LoadBusinessDataEvent event,
    Emitter<AddExpenseState> emit,
  ) async {
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

  Future<void> _onSaveExpense(
    SaveExpenseEvent event,
    Emitter<AddExpenseState> emit,
  ) async {
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
                 (state.customCategory == null || state.customCategory!.trim().isEmpty)) {
        errorMessage = 'Please enter a custom category name';
      }
      emit(state.copyWith(error: errorMessage));
      return;
    }

    try {
      emit(state.copyWith(isSaving: true, clearError: true));

      final expenseApiService = serviceLocator.expenseApiService;

      if (event.expenseIdToEdit != null && event.expenseIdToEdit!.isNotEmpty) {
        // Update existing expense - PUT /api/expenses/:id (NEVER use POST for updates)
        debugPrint('✏️ Updating expense: ${event.expenseIdToEdit}');
        debugPrint('   Account: ${state.accountId}');
        debugPrint('   Amount: ${state.amount}');
        debugPrint('   Category: ${state.category}');
        debugPrint('   Date: ${state.date}');

        final updatedExpense = await expenseApiService.updateExpense(
          event.expenseIdToEdit!,
          accountId:
              state.accountId?.isNotEmpty == true ? state.accountId : null,
          amount: state.amount > 0 ? state.amount : null,
          category: state.category.isNotEmpty ? state.category : null,
          customCategory: state.category == 'أخرى' && 
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
          customCategory: state.category == 'أخرى' && 
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
