// ✅ Add Expense Dialog - Refactored with BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/add_expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/add_expense_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/amount_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/category_selector.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/custom_category_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/date_picker_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/account_dropdown.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/notes_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/business_fields.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/save_button.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/core/constants/categories.dart';
import 'package:expense_tracker/core/constants/category_constants.dart'
    show CategoryType;
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';

class AddExpenseDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Expense? expenseToEdit;
  final List<Project>? projects;
  final List<String>? vendorNames;

  const AddExpenseDialog({
    super.key,
    required this.selectedDate,
    this.expenseToEdit,
    this.projects,
    this.vendorNames,
  });

  /// Creates the dialog wrapped in [BlocProvider] with [AddExpenseCubit].
  /// Use this so UI does not call getIt directly; composition root is centralized here.
  static Widget createWithCubit(
    BuildContext context, {
    required DateTime selectedDate,
    Expense? expenseToEdit,
    List<Project>? projects,
    List<String>? vendorNames,
  }) {
    final settings = context.read<SettingsCubit>().state;
    final cubit = AddExpenseCubit(
      initialDate: selectedDate,
      appMode: settings.appMode,
      expenseToEdit: expenseToEdit,
      addExpenseUseCase: getIt<AddExpenseUseCase>(),
      updateExpenseUseCase: getIt<UpdateExpenseUseCase>(),
    );
    if (settings.appMode == AppMode.business &&
        projects != null &&
        vendorNames != null) {
      cubit.setBusinessData(projects: projects, vendorNames: vendorNames);
    } else {
      cubit.loadBusinessData();
    }
    return BlocProvider<AddExpenseCubit>.value(
      value: cubit,
      child: AddExpenseDialog(
        selectedDate: selectedDate,
        expenseToEdit: expenseToEdit,
        projects: projects,
        vendorNames: vendorNames,
      ),
    );
  }

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _departmentController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize form controllers with expense data if editing
    if (widget.expenseToEdit != null) {
      _customCategoryController.text =
          widget.expenseToEdit!.customCategory ?? '';
      _departmentController.text = widget.expenseToEdit!.department ?? '';
      _invoiceNumberController.text = widget.expenseToEdit!.invoiceNumber ?? '';
      _vendorNameController.text = widget.expenseToEdit!.vendorName ?? '';
    }
  }

  // Sync controllers with BLoC state when editing
  void _syncControllersWithBlocState(AddExpenseState state) {
    if (widget.expenseToEdit != null) {
      if (_amountController.text.isEmpty ||
          double.tryParse(_amountController.text) != state.amount) {
        _amountController.text = state.amount.toString();
      }
      if (_notesController.text != state.notes) {
        _notesController.text = state.notes;
      }
      if (state.department != null &&
          _departmentController.text != state.department) {
        _departmentController.text = state.department!;
      }
      if (state.invoiceNumber != null &&
          _invoiceNumberController.text != state.invoiceNumber) {
        _invoiceNumberController.text = state.invoiceNumber!;
      }
      if (state.vendorName != null &&
          _vendorNameController.text != state.vendorName) {
        _vendorNameController.text = state.vendorName!;
      }
      if (state.customCategory != null &&
          _customCategoryController.text != state.customCategory) {
        _customCategoryController.text = state.customCategory!;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _customCategoryController.dispose();
    _departmentController.dispose();
    _invoiceNumberController.dispose();
    _vendorNameController.dispose();
    super.dispose();
  }

  void _handleSave(
    BuildContext context,
    AddExpenseState state,
    SettingsState settings,
  ) {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.expenseToEdit == null) {
        // For new expenses: Only dispatch AddExpense to ExpenseCubit
        // ExpenseCubit handles optimistic update + API call (no duplicate API call)
        final expenseId = const Uuid().v4();
        final expense = Expense(
          id: expenseId,
          amount: state.amount,
          category: state.category,
          customCategory:
              state.category == 'أخرى' &&
                      state.customCategory?.isNotEmpty == true
                  ? state.customCategory
                  : null,
          notes: state.notes,
          date: state.date,
          accountId: state.accountId ?? '',
          appMode: settings.appMode,
          projectId: state.projectId,
          department: state.department,
          invoiceNumber: state.invoiceNumber,
          vendorName: state.vendorName,
          employeeId: state.employeeId,
        );

        // Dispatch AddExpense to ExpenseCubit (handles optimistic update + API call)
        context.read<ExpenseCubit>().addExpense(expense);
        debugPrint(
          '✅ Dispatched AddExpense to ExpenseCubit for optimistic update: $expenseId',
        );

        // Close dialog immediately after optimistic update (no need to wait for API)
        context.pop();

        // Show success message
        final isRTL = settings.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  isRTL
                      ? 'تم إضافة المصروف بنجاح'
                      : 'Expense added successfully',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // For edits: Dispatch SaveExpenseEvent to AddExpenseCubit (handles API call)
        context.read<AddExpenseCubit>().saveExpense(
          expenseIdToEdit: widget.expenseToEdit?.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          // Set default category and account if not editing
          if (widget.expenseToEdit == null) {
            final categories = Categories.getCategoriesForType(
              settings.isBusinessMode,
              CategoryType.expense,
            );
            if (categories.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final defaultCategory = Categories.getDefaultCategoryForType(
                  settings.isBusinessMode,
                  CategoryType.expense,
                );
                context.read<AddExpenseCubit>().changeCategory(defaultCategory);
              });
            }

            // Set default account for new expense (NOT selectedAccount for filtering)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final accountState = context.read<AccountCubit>().state;
              final defaultAccountId = accountState.defaultAccount?.id;
              final addExpenseState = context.read<AddExpenseCubit>().state;

              // Only set if not already set and defaultAccount exists
              if (addExpenseState.accountId == null &&
                  defaultAccountId != null) {
                context.read<AddExpenseCubit>().changeAccount(defaultAccountId);
              }
            });
          }

          return BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              return BlocBuilder<UserCubit, UserState>(
                builder: (context, userState) {
                  final isRTL = settings.language == 'ar';
                  final isDesktop = context.isDesktop;
                  final maxWidth = ResponsiveUtils.getDialogWidth(context);

                  return BlocConsumer<AddExpenseCubit, AddExpenseState>(
                    listener: (context, state) {
                      // Sync controllers with BLoC state on first build when editing
                      if (widget.expenseToEdit != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _syncControllersWithBlocState(state);
                        });
                      }

                      if (state.saveSuccess) {
                        // For edits, refresh expenses list (optimistic update already handled for new expenses)
                        if (widget.expenseToEdit != null) {
                          // Reload expenses for edits (in case edit changed date/account that affects filtering)
                          context.read<ExpenseCubit>().loadExpenses(
                            forceRefresh: true,
                          );
                        }

                        // Navigate back with result
                        final result = widget.expenseToEdit;
                        context.pop(result);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.expenseToEdit != null
                                      ? (isRTL
                                          ? 'تم تحديث المصروف بنجاح'
                                          : 'Expense updated successfully')
                                      : (isRTL
                                          ? 'تم إضافة المصروف بنجاح'
                                          : 'Expense added successfully'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }

                      if (state.error != null && !state.isSaving) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.error!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                            action: SnackBarAction(
                              label: isRTL ? 'إغلاق' : 'Dismiss',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, addExpenseState) {
                      return Directionality(
                        textDirection:
                            isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors:
                                  settings.isDarkMode
                                      ? [
                                        Colors.grey[900]!.withValues(
                                          alpha: 0.9,
                                        ),
                                        Colors.grey[800]!.withValues(
                                          alpha: 0.8,
                                        ),
                                      ]
                                      : [
                                        Colors.grey[50]!.withValues(
                                          alpha: 0.95,
                                        ),
                                        Colors.grey[100]!.withValues(
                                          alpha: 0.9,
                                        ),
                                      ],
                            ),
                          ),
                          child: Scaffold(
                            backgroundColor: Colors.transparent,
                            appBar: AppBar(
                              backgroundColor: settings.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              elevation: 0,
                              leading: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: settings.primaryTextColor,
                                ),
                                onPressed: () => context.pop(),
                              ),
                              title: Text(
                                widget.expenseToEdit != null
                                    ? (isRTL ? 'تعديل المصروف' : 'Edit Expense')
                                    : (isRTL ? 'إضافة مصروف' : 'Add Expense'),
                                style: TextStyle(
                                  color: settings.primaryTextColor,
                                  fontSize: isDesktop ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            body: SafeArea(
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.all(isDesktop ? 24 : 16),
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        isDesktop ? maxWidth : double.infinity,
                                    maxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: settings.surfaceColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            settings.isDarkMode
                                                ? Colors.black.withValues(
                                                  alpha: 0.3,
                                                )
                                                : Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            padding: EdgeInsets.all(
                                              isDesktop ? 32 : 24,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                AmountField(
                                                  controller: _amountController,
                                                  currencySymbol:
                                                      settings.currencySymbol,
                                                  isRTL: isRTL,
                                                  onChanged: (amount) {
                                                    if (amount != null) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeAmount(amount);
                                                    }
                                                  },
                                                ),
                                                const SizedBox(height: 16),

                                                AccountDropdown(
                                                  selectedAccountId:
                                                      addExpenseState.accountId,
                                                  accounts:
                                                      accountState.accounts,
                                                  isRTL: isRTL,
                                                  onChanged: (accountId) {
                                                    context
                                                        .read<AddExpenseCubit>()
                                                        .changeAccount(
                                                          accountId,
                                                        );
                                                  },
                                                ),
                                                const SizedBox(height: 16),

                                                CategorySelector(
                                                  selectedCategory:
                                                      addExpenseState.category,
                                                  isBusinessMode:
                                                      settings.isBusinessMode,
                                                  isRTL: isRTL,
                                                  onChanged: (category) {
                                                    context
                                                        .read<AddExpenseCubit>()
                                                        .changeCategory(
                                                          category,
                                                        );
                                                  },
                                                ),
                                                // Show custom category field when "أخرى" is selected
                                                if (addExpenseState.category ==
                                                    'أخرى')
                                                  Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 16,
                                                      ),
                                                      CustomCategoryField(
                                                        controller:
                                                            _customCategoryController,
                                                        isRTL: isRTL,
                                                        validator: (value) {
                                                          if (addExpenseState
                                                                      .category ==
                                                                  'أخرى' &&
                                                              (value == null ||
                                                                  value
                                                                      .trim()
                                                                      .isEmpty)) {
                                                            return isRTL
                                                                ? 'يرجى إدخال اسم الفئة المخصصة'
                                                                : 'Please enter a custom category name';
                                                          }
                                                          return null;
                                                        },
                                                        onChanged: (value) {
                                                          context
                                                              .read<
                                                                AddExpenseCubit
                                                              >()
                                                              .changeCustomCategory(
                                                                value.trim(),
                                                              );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                const SizedBox(height: 16),

                                                DatePickerField(
                                                  selectedDate:
                                                      addExpenseState.date,
                                                  isRTL: isRTL,
                                                  onDateChanged: (date) {
                                                    context
                                                        .read<AddExpenseCubit>()
                                                        .changeDate(date);
                                                  },
                                                ),
                                                const SizedBox(height: 16),

                                                NotesField(
                                                  controller: _notesController,
                                                  isRTL: isRTL,
                                                  onChanged: (notes) {
                                                    context
                                                        .read<AddExpenseCubit>()
                                                        .changeNotes(notes);
                                                  },
                                                ),
                                                const SizedBox(height: 16),

                                                if (settings.isBusinessMode &&
                                                    !addExpenseState
                                                        .isLoadingBusinessData)
                                                  BusinessFields(
                                                    isRTL: isRTL,
                                                    selectedProjectId:
                                                        addExpenseState
                                                            .projectId,
                                                    availableProjects:
                                                        addExpenseState
                                                            .availableProjects,
                                                    departmentController:
                                                        _departmentController,
                                                    invoiceNumberController:
                                                        _invoiceNumberController,
                                                    vendorNameController:
                                                        _vendorNameController,
                                                    availableVendors:
                                                        addExpenseState
                                                            .availableVendors,
                                                    selectedEmployeeId:
                                                        addExpenseState
                                                            .employeeId,
                                                    availableEmployees:
                                                        settings.isBusinessMode &&
                                                                userState
                                                                    is UserLoaded
                                                            ? userState.users
                                                            : <UserEntity>[],
                                                    onProjectChanged: (
                                                      projectId,
                                                    ) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeProject(
                                                            projectId,
                                                          );
                                                    },
                                                    onEmployeeChanged: (
                                                      employeeId,
                                                    ) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeEmployee(
                                                            employeeId,
                                                          );
                                                    },
                                                    onDepartmentChanged: (
                                                      department,
                                                    ) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeDepartment(
                                                            department,
                                                          );
                                                    },
                                                    onInvoiceNumberChanged: (
                                                      invoice,
                                                    ) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeInvoiceNumber(
                                                            invoice,
                                                          );
                                                    },
                                                    onVendorChanged: (vendor) {
                                                      context
                                                          .read<
                                                            AddExpenseCubit
                                                          >()
                                                          .changeVendor(vendor);
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.all(
                                            isDesktop ? 32 : 24,
                                          ),
                                          child: SaveButton(
                                            isLoading: addExpenseState.isSaving,
                                            isRTL: isRTL,
                                            isEditMode:
                                                widget.expenseToEdit != null,
                                            onPressed:
                                                () => _handleSave(
                                                  context,
                                                  addExpenseState,
                                                  settings,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
    );
  }
}
