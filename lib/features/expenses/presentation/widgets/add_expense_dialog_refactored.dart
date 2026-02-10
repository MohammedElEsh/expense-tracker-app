// ✅ Add Expense Dialog - Refactored with BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/add_expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/add_expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/add_expense_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/amount_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/category_selector.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/custom_category_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/date_picker_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/account_dropdown.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/notes_field.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/business_fields.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense/save_button.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/constants/category_constants.dart' show CategoryType;
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

class AddExpenseDialogRefactored extends StatefulWidget {
  final DateTime selectedDate;
  final Expense? expenseToEdit;

  const AddExpenseDialogRefactored({
    super.key,
    required this.selectedDate,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseDialogRefactored> createState() =>
      _AddExpenseDialogRefactoredState();
}

class _AddExpenseDialogRefactoredState
    extends State<AddExpenseDialogRefactored> {
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
        // For new expenses: Only dispatch AddExpense to ExpenseBloc
        // ExpenseBloc handles optimistic update + API call (no duplicate API call)
        final expenseId = const Uuid().v4();
        final expense = Expense(
          id: expenseId,
          amount: state.amount,
          category: state.category,
          customCategory: state.category == 'أخرى' && 
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
        
        // Dispatch AddExpense to ExpenseBloc (handles optimistic update + API call)
        context.read<ExpenseBloc>().add(AddExpense(expense));
        debugPrint('✅ Dispatched AddExpense to ExpenseBloc for optimistic update: $expenseId');
        
        // Close dialog immediately after optimistic update (no need to wait for API)
        Navigator.of(context).pop();
        
        // Show success message
        final isRTL = settings.language == 'ar';
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
                  isRTL ? 'تم إضافة المصروف بنجاح' : 'Expense added successfully',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // For edits: Dispatch SaveExpenseEvent to AddExpenseBloc (handles API call)
        context.read<AddExpenseBloc>().add(
          SaveExpenseEvent(expenseIdToEdit: widget.expenseToEdit?.id),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final settings = context.read<SettingsBloc>().state;

        final bloc = AddExpenseBloc(
          initialDate: widget.selectedDate,
          appMode: settings.appMode,
          expenseToEdit: widget.expenseToEdit, // ✅ Pass expense to edit
        );

        bloc.add(const LoadBusinessDataEvent());
        return bloc;
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
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
                context.read<AddExpenseBloc>().add(
                  ChangeCategoryEvent(defaultCategory),
                );
                            });
            }
            
            // Set default account for new expense (NOT selectedAccount for filtering)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final accountState = context.read<AccountBloc>().state;
              final defaultAccountId = accountState.defaultAccount?.id;
              final addExpenseState = context.read<AddExpenseBloc>().state;
              
              // Only set if not already set and defaultAccount exists
              if (addExpenseState.accountId == null && defaultAccountId != null) {
                context.read<AddExpenseBloc>().add(
                  ChangeAccountEvent(defaultAccountId),
                );
              }
            });
          }

          return BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              return BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  final isRTL = settings.language == 'ar';
                  final isDesktop = context.isDesktop;
                  final maxWidth = ResponsiveUtils.getDialogWidth(context);

                  return BlocConsumer<AddExpenseBloc, AddExpenseState>(
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
                              context.read<ExpenseBloc>().add(
                                const LoadExpenses(forceRefresh: true),
                              );
                            }

                            // Navigate back with result
                            final result = widget.expenseToEdit;
                            Navigator.of(context).pop(result);

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
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
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
                                isRTL
                                    ? ui.TextDirection.rtl
                                    : ui.TextDirection.ltr,
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
                                  backgroundColor: settings.primaryColor
                                      .withValues(alpha: 0.1),
                                  elevation: 0,
                                  leading: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: settings.primaryTextColor,
                                    ),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                  ),
                                  title: Text(
                                    widget.expenseToEdit != null
                                        ? (isRTL
                                            ? 'تعديل المصروف'
                                            : 'Edit Expense')
                                        : (isRTL
                                            ? 'إضافة مصروف'
                                            : 'Add Expense'),
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
                                      margin: EdgeInsets.all(
                                        isDesktop ? 24 : 16,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            isDesktop
                                                ? maxWidth
                                                : double.infinity,
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
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    AmountField(
                                                      controller:
                                                          _amountController,
                                                      currencySymbol:
                                                          settings
                                                              .currencySymbol,
                                                      isRTL: isRTL,
                                                      onChanged: (amount) {
                                                        if (amount != null) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeAmountEvent(
                                                                  amount,
                                                                ),
                                                              );
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(height: 16),

                                                    AccountDropdown(
                                                      selectedAccountId:
                                                          addExpenseState
                                                              .accountId,
                                                      accounts:
                                                          accountState.accounts,
                                                      isRTL: isRTL,
                                                      onChanged: (accountId) {
                                                        context
                                                            .read<
                                                              AddExpenseBloc
                                                            >()
                                                            .add(
                                                              ChangeAccountEvent(
                                                                accountId,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                    const SizedBox(height: 16),

                                                    CategorySelector(
                                                      selectedCategory:
                                                          addExpenseState
                                                              .category,
                                                      isBusinessMode:
                                                          settings
                                                              .isBusinessMode,
                                                      isRTL: isRTL,
                                                      onChanged: (category) {
                                                        context
                                                            .read<
                                                              AddExpenseBloc
                                                            >()
                                                            .add(
                                                              ChangeCategoryEvent(
                                                                category,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                    // Show custom category field when "أخرى" is selected
                                                    if (addExpenseState
                                                            .category ==
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
                                                                  (value ==
                                                                          null ||
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
                                                                    AddExpenseBloc
                                                                  >()
                                                                  .add(
                                                                    ChangeCustomCategoryEvent(
                                                                      value
                                                                          .trim(),
                                                                    ),
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
                                                            .read<
                                                              AddExpenseBloc
                                                            >()
                                                            .add(
                                                              ChangeDateEvent(
                                                                date,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                    const SizedBox(height: 16),

                                                    NotesField(
                                                      controller:
                                                          _notesController,
                                                      isRTL: isRTL,
                                                      onChanged: (notes) {
                                                        context
                                                            .read<
                                                              AddExpenseBloc
                                                            >()
                                                            .add(
                                                              ChangeNotesEvent(
                                                                notes,
                                                              ),
                                                            );
                                                      },
                                                    ),
                                                    const SizedBox(height: 16),

                                                    if (settings
                                                            .isBusinessMode &&
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
                                                            settings.isBusinessMode
                                                                ? userState
                                                                    .activeUsers
                                                                : [],
                                                        onProjectChanged: (
                                                          projectId,
                                                        ) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeProjectEvent(
                                                                  projectId,
                                                                ),
                                                              );
                                                        },
                                                        onEmployeeChanged: (
                                                          employeeId,
                                                        ) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeEmployeeEvent(
                                                                  employeeId,
                                                                ),
                                                              );
                                                        },
                                                        onDepartmentChanged: (
                                                          department,
                                                        ) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeDepartmentEvent(
                                                                  department,
                                                                ),
                                                              );
                                                        },
                                                        onInvoiceNumberChanged: (
                                                          invoice,
                                                        ) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeInvoiceNumberEvent(
                                                                  invoice,
                                                                ),
                                                              );
                                                        },
                                                        onVendorChanged: (
                                                          vendor,
                                                        ) {
                                                          context
                                                              .read<
                                                                AddExpenseBloc
                                                              >()
                                                              .add(
                                                                ChangeVendorEvent(
                                                                  vendor,
                                                                ),
                                                              );
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
                                                isLoading:
                                                    addExpenseState.isSaving,
                                                isRTL: isRTL,
                                                isEditMode:
                                                    widget.expenseToEdit !=
                                                    null,
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
          ),
    );
  }
}
