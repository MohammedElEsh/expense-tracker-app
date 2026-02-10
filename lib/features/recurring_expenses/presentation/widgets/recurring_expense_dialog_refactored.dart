// ✅ Recurring Expense Dialog - Using API Service
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/constants/category_constants.dart' show CategoryType;
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';

class RecurringExpenseDialogRefactored extends StatefulWidget {
  final RecurringExpense? recurringExpense;

  const RecurringExpenseDialogRefactored({super.key, this.recurringExpense});

  @override
  State<RecurringExpenseDialogRefactored> createState() =>
      _RecurringExpenseDialogRefactoredState();
}

class _RecurringExpenseDialogRefactoredState
    extends State<RecurringExpenseDialogRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = '';
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  int _dayOfMonth = DateTime.now().day;
  int _dayOfWeek = DateTime.now().weekday;
  String? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recurringExpense != null) {
      _initializeWithRecurringExpense(widget.recurringExpense!);
    } else {
      // Set default account
      final accountState = context.read<AccountBloc>().state;
      if (accountState.accounts.isNotEmpty) {
        _selectedAccountId = accountState.accounts.first.id;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default category based on app mode if not already set
    if (_category.isEmpty && widget.recurringExpense == null) {
      final settings = context.read<SettingsBloc>().state;
      final isBusinessMode = settings.appMode == AppMode.business;
      _category = Categories.getDefaultCategoryForType(
        isBusinessMode,
        CategoryType.recurringExpense,
      );
    }
  }

  void _initializeWithRecurringExpense(RecurringExpense expense) {
    _amountController.text = expense.amount.toString();
    _notesController.text = expense.notes;
    _category = expense.category;
    _recurrenceType = expense.recurrenceType;
    _dayOfMonth = expense.dayOfMonth ?? DateTime.now().day;
    _dayOfWeek = expense.dayOfWeek ?? DateTime.now().weekday;
    _selectedAccountId = expense.accountId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecurringExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountId == null) {
      final isRTL = context.read<SettingsBloc>().state.language == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'يرجى اختيار حساب' : 'Please select an account',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final settings = context.read<SettingsBloc>().state;

      final isEditing = widget.recurringExpense != null;

      final recurringExpense = RecurringExpense(
        id: widget.recurringExpense?.id ?? '',
        accountId: _selectedAccountId!,
        amount: double.parse(_amountController.text),
        category: _category,
        notes: _notesController.text.trim(),
        recurrenceType: _recurrenceType,
        dayOfMonth:
            _recurrenceType == RecurrenceType.monthly ||
                    _recurrenceType == RecurrenceType.yearly
                ? _dayOfMonth
                : null,
        dayOfWeek: _recurrenceType == RecurrenceType.weekly ? _dayOfWeek : null,
        appMode: settings.appMode,
        isActive: widget.recurringExpense?.isActive ?? true,
      );

      // Use BLoC to add or update the expense
      if (isEditing) {
        context.read<RecurringExpenseBloc>().add(
          UpdateRecurringExpense(recurringExpense),
        );
      } else {
        context.read<RecurringExpenseBloc>().add(
          AddRecurringExpense(recurringExpense),
        );
      }

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsBloc>().state.language == 'ar';
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRTL ? 'خطأ: $e' : 'Error: $e'),
            backgroundColor:
                isDarkMode ? Colors.red.shade800 : Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = ResponsiveUtils.getDialogWidth(context);
    final isEditing = widget.recurringExpense != null;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final categories = Categories.reorderCategories(
          Categories.getCategoriesForType(
            settings.isBusinessMode,
            CategoryType.recurringExpense,
          ),
        );

        // Get accounts from AccountBloc
        final accountState = context.watch<AccountBloc>().state;
        final accounts = accountState.accounts;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? maxWidth : 500,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: settings.primaryColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(context.borderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color:
                              settings.isDarkMode ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing
                                ? (isRTL
                                    ? 'تعديل المصروف المتكرر'
                                    : 'Edit Recurring Expense')
                                : (isRTL
                                    ? 'مصروف متكرر جديد'
                                    : 'New Recurring Expense'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  settings.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color:
                                settings.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Account Selection
                          DropdownButtonFormField<String>(
                            initialValue: _selectedAccountId,
                            decoration: InputDecoration(
                              labelText: isRTL ? 'الحساب *' : 'Account *',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet,
                              ),
                            ),
                            items:
                                accounts.map((Account account) {
                                  return DropdownMenuItem<String>(
                                    value: account.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          account.icon,
                                          size: 20,
                                          color: account.color,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(account.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedAccountId = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isRTL
                                    ? 'يرجى اختيار حساب'
                                    : 'Please select an account';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Amount
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: isRTL ? 'المبلغ *' : 'Amount *',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.attach_money),
                              prefixText: '${settings.currencySymbol} ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return isRTL
                                    ? 'يرجى إدخال المبلغ'
                                    : 'Please enter amount';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return isRTL
                                    ? 'المبلغ يجب أن يكون أكبر من صفر'
                                    : 'Amount must be greater than zero';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category
                          DropdownButtonFormField<String>(
                            initialValue:
                                categories.contains(_category)
                                    ? _category
                                    : categories.first,
                            decoration: InputDecoration(
                              labelText: isRTL ? 'الفئة *' : 'Category *',
                              border: const OutlineInputBorder(),
                              prefixIcon: Icon(Categories.getIcon(_category)),
                            ),
                            items:
                                categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Row(
                                      children: [
                                        Icon(Categories.getIcon(cat), size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          isRTL
                                              ? Categories.getArabicName(cat)
                                              : cat,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Recurrence Type
                          DropdownButtonFormField<RecurrenceType>(
                            initialValue: _recurrenceType,
                            decoration: InputDecoration(
                              labelText:
                                  isRTL ? 'نوع التكرار *' : 'Recurrence Type *',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.repeat),
                            ),
                            items:
                                RecurrenceType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      isRTL
                                          ? type.displayName
                                          : type.englishName,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _recurrenceType = value;
                                  // Reset day values based on type
                                  if (value == RecurrenceType.weekly &&
                                      _dayOfWeek > 7) {
                                    _dayOfWeek = 1;
                                  } else if (value == RecurrenceType.monthly &&
                                      _dayOfMonth > 31) {
                                    _dayOfMonth = 1;
                                  }
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Day of Month (for monthly/yearly)
                          if (_recurrenceType == RecurrenceType.monthly ||
                              _recurrenceType == RecurrenceType.yearly)
                            DropdownButtonFormField<int>(
                              initialValue: _dayOfMonth.clamp(1, 31),
                              decoration: InputDecoration(
                                labelText:
                                    isRTL ? 'يوم الشهر *' : 'Day of Month *',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              items:
                                  List.generate(31, (index) => index + 1).map((
                                    day,
                                  ) {
                                    return DropdownMenuItem(
                                      value: day,
                                      child: Text('$day'),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _dayOfMonth = value);
                                }
                              },
                            ),

                          // Day of Week (for weekly)
                          if (_recurrenceType == RecurrenceType.weekly)
                            DropdownButtonFormField<int>(
                              initialValue: _dayOfWeek.clamp(1, 7),
                              decoration: InputDecoration(
                                labelText:
                                    isRTL ? 'يوم الأسبوع *' : 'Day of Week *',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(isRTL ? 'الاثنين' : 'Monday'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(isRTL ? 'الثلاثاء' : 'Tuesday'),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(isRTL ? 'الأربعاء' : 'Wednesday'),
                                ),
                                DropdownMenuItem(
                                  value: 4,
                                  child: Text(isRTL ? 'الخميس' : 'Thursday'),
                                ),
                                DropdownMenuItem(
                                  value: 5,
                                  child: Text(isRTL ? 'الجمعة' : 'Friday'),
                                ),
                                DropdownMenuItem(
                                  value: 6,
                                  child: Text(isRTL ? 'السبت' : 'Saturday'),
                                ),
                                DropdownMenuItem(
                                  value: 7,
                                  child: Text(isRTL ? 'الأحد' : 'Sunday'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _dayOfWeek = value);
                                }
                              },
                            ),

                          if (_recurrenceType == RecurrenceType.monthly ||
                              _recurrenceType == RecurrenceType.weekly ||
                              _recurrenceType == RecurrenceType.yearly)
                            const SizedBox(height: 16),

                          // Notes
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: isRTL ? 'ملاحظات' : 'Notes',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.note),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveRecurringExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settings.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  isEditing
                                      ? (isRTL ? 'تحديث' : 'Update')
                                      : (isRTL ? 'إضافة' : 'Add'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        settings.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
