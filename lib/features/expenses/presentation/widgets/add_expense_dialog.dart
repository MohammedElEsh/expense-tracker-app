// ✅ Clean Architecture - Add Expense Dialog Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/constants/category_constants.dart' show CategoryType;
import 'package:expense_tracker/services/image_service.dart';
import 'package:expense_tracker/services/permission_service.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

class AddExpenseDialog extends StatefulWidget {
  final DateTime selectedDate;
  final Expense? expenseToEdit;

  const AddExpenseDialog({
    super.key,
    required this.selectedDate,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();

  String _selectedCategory = '';
  DateTime? _selectedDate;
  String? _selectedImagePath;
  String? _selectedAccountId;
  String? _selectedEmployeeId;
  String? _selectedProjectId;
  List<Project> _availableProjects = [];
  List<String> _availableVendors = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _loadBusinessData();

    // ✅ تحميل بيانات المصروف للتعديل
    if (widget.expenseToEdit != null) {
      _loadExpenseData(widget.expenseToEdit!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set default category based on app mode if not already set
    if (_selectedCategory.isEmpty && widget.expenseToEdit == null) {
      final settings = context.read<SettingsBloc>().state;
      _selectedCategory = Categories.getDefaultCategoryForType(
        settings.isBusinessMode,
        CategoryType.expense,
      );
    }
    
    // Set default account if not set
    if (_selectedAccountId == null) {
      final accountState = context.read<AccountBloc>().state;

      // تأكد من أن الحساب المحدد موجود في القائمة
      final selectedId = accountState.selectedAccount?.id;
      if (selectedId != null &&
          accountState.accounts.any((acc) => acc.id == selectedId)) {
        _selectedAccountId = selectedId;
      } else if (accountState.accounts.isNotEmpty) {
        // اختر أول حساب نشط
        _selectedAccountId =
            accountState.activeAccounts.isNotEmpty
                ? accountState.activeAccounts.first.id
                : accountState.accounts.first.id;
      }
    }

    // تحديد الموظف الافتراضي (المستخدم الحالي)
    if (_selectedEmployeeId == null) {
      final userState = context.read<UserBloc>().state;
      if (userState.currentUser != null) {
        _selectedEmployeeId = userState.currentUser!.id;
      }
    }
  }

  void _loadExpenseData(Expense expense) {
    _amountController.text = expense.amount.toString();
    _notesController.text = expense.notes;
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
    _selectedAccountId = expense.accountId;
    _selectedImagePath = expense.photoPath;

    // بيانات تجارية
    _selectedProjectId = expense.projectId;
    _departmentController.text = expense.department ?? '';
    _invoiceNumberController.text = expense.invoiceNumber ?? '';
    _vendorNameController.text = expense.vendorName ?? '';
    _selectedEmployeeId = expense.employeeId;
  }

  Future<void> _loadBusinessData() async {
    try {
      // جلب كل المشاريع ماعدا الملغاة والمكتملة
      final projectsResponse = await serviceLocator.projectService.getAllProjects(
        forceRefresh: false,
      );
      final projects =
          projectsResponse.projects
              .where(
                (p) =>
                    p.status != ProjectStatus.cancelled &&
                    p.status != ProjectStatus.completed,
              )
              .toList();

      final vendorService = serviceLocator.vendorService;
      final vendors = await vendorService.getAllVendors();
      final vendorNames = vendors.map((v) => v.name).toList();

      setState(() {
        _availableProjects = projects;
        _availableVendors = vendorNames;

        // التحقق من صحة القيم المحددة
        if (_selectedProjectId != null &&
            !projects.any((p) => p.id == _selectedProjectId)) {
          _selectedProjectId = null;
        }

        if (_vendorNameController.text.isNotEmpty &&
            !vendorNames.contains(_vendorNameController.text)) {
          _vendorNameController.text = '';
        }
      });
    } catch (e) {
      debugPrint('❌ خطأ في تحميل بيانات الأعمال: $e');
      // Handle error silently
    }
  }


  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _projectIdController.dispose();
    _departmentController.dispose();
    _invoiceNumberController.dispose();
    _vendorNameController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final source = await ImageService.showImageSourceDialog(context);
    if (source == null) return;

    String? imagePath;
    if (source == 'camera') {
      imagePath = await ImageService.captureImage();
    } else if (source == 'gallery') {
      imagePath = await ImageService.pickImageFromGallery();
    }

    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<void> _removePhoto() async {
    if (_selectedImagePath != null) {
      await ImageService.deleteImage(_selectedImagePath!);
      setState(() {
        _selectedImagePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<AccountBloc, AccountState>(
          builder: (context, accountState) {
            final isRTL = settings.language == 'ar';
            final theme = Theme.of(context);
            final isDesktop = context.isDesktop;
            final maxWidth = ResponsiveUtils.getDialogWidth(context);

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
                              Colors.grey[900]!.withValues(alpha: 0.9),
                              Colors.grey[800]!.withValues(alpha: 0.8),
                            ]
                            : [
                              Colors.grey[50]!.withValues(alpha: 0.95),
                              Colors.grey[100]!.withValues(alpha: 0.9),
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
                      icon: Icon(Icons.close, color: settings.primaryTextColor),
                      onPressed: () => Navigator.of(context).pop(),
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
                          maxWidth: isDesktop ? maxWidth : double.infinity,
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        decoration: BoxDecoration(
                          color: settings.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  settings.isDarkMode
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Fixed header
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Handle bar
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: settings.borderColor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    widget.expenseToEdit != null
                                        ? (isRTL
                                            ? 'تعديل المصروف'
                                            : 'Edit Expense')
                                        : (isRTL
                                            ? 'إضافة مصروف جديد'
                                            : 'Add New Expense'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: settings.primaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Scrollable content
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  bottom:
                                      24 +
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Amount Field
                                    TextFormField(
                                      controller: _amountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: InputDecoration(
                                        labelText: isRTL ? 'المبلغ' : 'Amount',
                                        prefixText:
                                            '${settings.currencySymbol} ',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(
                                          Icons.attach_money,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Account Selection
                                    if (accountState.accounts.isNotEmpty) ...[
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedAccountId,
                                        decoration: InputDecoration(
                                          labelText:
                                              isRTL ? 'الحساب' : 'Account',
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(
                                            Icons.account_balance_wallet,
                                          ),
                                        ),
                                        items:
                                            accountState.accounts
                                                .fold<Map<String, Account>>(
                                                  {},
                                                  (map, account) {
                                                    map[account.id] = account;
                                                    return map;
                                                  },
                                                )
                                                .values
                                                .map((account) {
                                                  return DropdownMenuItem(
                                                    value: account.id,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          account.icon,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          account.name,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedAccountId = value;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],

                                    // Category Dropdown
                                    BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, settings) {
                                        final categories = Categories.reorderCategories(
                                          Categories.getCategoriesForType(
                                            settings.isBusinessMode,
                                            CategoryType.expense,
                                          ),
                                        );
                                        if (!categories.contains(
                                          _selectedCategory,
                                        )) {
                                          _selectedCategory =
                                              Categories.getDefaultCategoryForType(
                                                settings.isBusinessMode,
                                                CategoryType.expense,
                                              );
                                        }

                                        return DropdownButtonFormField<String>(
                                          initialValue: _selectedCategory,
                                          decoration: InputDecoration(
                                            labelText:
                                                isRTL ? 'الفئة' : 'Category',
                                            border: const OutlineInputBorder(),
                                            prefixIcon: const Icon(
                                              Icons.category,
                                            ),
                                          ),
                                          items:
                                              categories.map((category) {
                                                return DropdownMenuItem(
                                                  value: category,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Categories.getIcon(
                                                          category,
                                                        ),
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        Categories.getDisplayName(
                                                          category,
                                                          isRTL,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCategory = value!;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Date Field
                                    InkWell(
                                      onTap: _selectDate,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: isRTL ? 'التاريخ' : 'Date',
                                          border: const OutlineInputBorder(),
                                          prefixIcon: const Icon(
                                            Icons.calendar_today,
                                          ),
                                        ),
                                        child: Text(
                                          DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(_selectedDate!),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Notes Field
                                    TextFormField(
                                      controller: _notesController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: isRTL ? 'ملاحظات' : 'Notes',
                                        border: const OutlineInputBorder(),
                                        prefixIcon: const Icon(Icons.note),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Employee Selection (في البيزنس مود فقط وللأدوار المصرح لها)
                                    BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, settings) {
                                        if (!settings.isBusinessMode) {
                                          return const SizedBox.shrink();
                                        }

                                        return BlocBuilder<UserBloc, UserState>(
                                          builder: (context, userState) {
                                            final currentUser =
                                                userState.currentUser;

                                            // فقط المدير والمحاسب يمكنهما اختيار موظف مختلف
                                            final canSelectEmployee =
                                                PermissionService.canManageExpenses(
                                                  currentUser,
                                                );

                                            if (!canSelectEmployee) {
                                              return const SizedBox.shrink();
                                            }

                                            return Column(
                                              children: [
                                                DropdownButtonFormField<String>(
                                                  initialValue:
                                                      userState.users.any(
                                                            (u) =>
                                                                u.id ==
                                                                _selectedEmployeeId,
                                                          )
                                                          ? _selectedEmployeeId
                                                          : null,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        isRTL
                                                            ? 'الموظف'
                                                            : 'Employee',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    prefixIcon: const Icon(
                                                      Icons.person,
                                                    ),
                                                  ),
                                                  items:
                                                      userState.users
                                                          .fold<
                                                            Map<String, User>
                                                          >({}, (map, user) {
                                                            map[user.id] = user;
                                                            return map;
                                                          })
                                                          .values
                                                          .map((user) {
                                                            return DropdownMenuItem(
                                                              value: user.id,
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 20,
                                                                    color:
                                                                        Theme.of(
                                                                          context,
                                                                        ).colorScheme.primary,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Text(
                                                                    '${user.name} (${user.role.getDisplayName(isRTL)})',
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          })
                                                          .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedEmployeeId =
                                                          value;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),

                                    // Business Fields (only show in business mode)
                                    BlocBuilder<SettingsBloc, SettingsState>(
                                      builder: (context, settings) {
                                        if (!settings.isBusinessMode) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isRTL
                                                  ? 'معلومات تجارية'
                                                  : 'Business Information',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    settings.primaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Project Selection
                                            DropdownButtonFormField<String>(
                                              initialValue:
                                                  _selectedProjectId != null &&
                                                          _availableProjects.any(
                                                            (p) =>
                                                                p.id ==
                                                                _selectedProjectId,
                                                          )
                                                      ? _selectedProjectId
                                                      : null,
                                              decoration: InputDecoration(
                                                labelText:
                                                    isRTL
                                                        ? 'المشروع'
                                                        : 'Project',
                                                border:
                                                    const OutlineInputBorder(),
                                                prefixIcon: const Icon(
                                                  Icons.work,
                                                ),
                                                hintText:
                                                    isRTL
                                                        ? 'اختر مشروع'
                                                        : 'Select Project',
                                              ),
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value: null,
                                                  child: Text(
                                                    isRTL
                                                        ? 'بدون مشروع'
                                                        : 'No Project',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                                ..._availableProjects.map((
                                                  project,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: project.id,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    project
                                                                        .status
                                                                        .color,
                                                                shape:
                                                                    BoxShape
                                                                        .circle,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          project.name,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          '${project.remainingBudget.toStringAsFixed(0)} ر.س',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                project.isOverBudget
                                                                    ? Colors.red
                                                                    : Colors
                                                                        .green,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedProjectId = value;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 12),

                                            // Department
                                            TextFormField(
                                              controller: _departmentController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    isRTL
                                                        ? 'القسم'
                                                        : 'Department',
                                                border:
                                                    const OutlineInputBorder(),
                                                prefixIcon: const Icon(
                                                  Icons.business,
                                                ),
                                                hintText:
                                                    isRTL
                                                        ? 'اختياري'
                                                        : 'Optional',
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Invoice Number
                                            TextFormField(
                                              controller:
                                                  _invoiceNumberController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    isRTL
                                                        ? 'رقم الفاتورة'
                                                        : 'Invoice Number',
                                                border:
                                                    const OutlineInputBorder(),
                                                prefixIcon: const Icon(
                                                  Icons.receipt_long,
                                                ),
                                                hintText:
                                                    isRTL
                                                        ? 'اختياري'
                                                        : 'Optional',
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Vendor Selection
                                            DropdownButtonFormField<String>(
                                              initialValue:
                                                  _vendorNameController
                                                          .text
                                                          .isEmpty
                                                      ? null
                                                      : _availableVendors
                                                          .contains(
                                                            _vendorNameController
                                                                .text,
                                                          )
                                                      ? _vendorNameController
                                                          .text
                                                      : null,
                                              decoration: InputDecoration(
                                                labelText:
                                                    isRTL ? 'المورد' : 'Vendor',
                                                border:
                                                    const OutlineInputBorder(),
                                                prefixIcon: const Icon(
                                                  Icons.store,
                                                ),
                                                hintText:
                                                    isRTL
                                                        ? 'اختر مورد'
                                                        : 'Select Vendor',
                                              ),
                                              items: [
                                                DropdownMenuItem<String>(
                                                  value: null,
                                                  child: Text(
                                                    isRTL
                                                        ? 'بدون مورد'
                                                        : 'No Vendor',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                                ..._availableVendors.map((
                                                  vendorName,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: vendorName,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.business,
                                                          size: 16,
                                                          color: Colors.blue,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          vendorName,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                              onChanged: (value) {
                                                setState(() {
                                                  _vendorNameController.text =
                                                      value ?? '';
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                        );
                                      },
                                    ),

                                    // Photo Section
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isRTL
                                                  ? 'إضافة صورة'
                                                  : 'Add Photo',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    settings.primaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            if (_selectedImagePath != null) ...[
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                          _selectedImagePath!,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: IconButton(
                                                      onPressed: _removePhoto,
                                                      icon: const Icon(
                                                        Icons.close,
                                                      ),
                                                      style:
                                                          IconButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              InkWell(
                                                onTap: _addPhoto,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          settings.borderColor,
                                                      style: BorderStyle.solid,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.add_a_photo,
                                                        size: 48,
                                                        color:
                                                            settings
                                                                .secondaryTextColor,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        isRTL
                                                            ? 'إضافة صورة'
                                                            : 'Add Photo',
                                                        style: TextStyle(
                                                          color:
                                                              settings
                                                                  .secondaryTextColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              side: BorderSide(
                                                color: settings.borderColor,
                                              ),
                                              foregroundColor:
                                                  settings.primaryTextColor,
                                            ),
                                            child: Text(
                                              isRTL ? 'إلغاء' : 'Cancel',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _submitForm,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
                                            child: Text(
                                              widget.expenseToEdit != null
                                                  ? (isRTL ? 'تعديل' : 'Update')
                                                  : (isRTL ? 'إضافة' : 'Add'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
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
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<SettingsBloc>().state.language == 'ar'
                ? 'يرجى إدخال مبلغ صحيح'
                : 'Please enter a valid amount',
          ),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    final settings = context.read<SettingsBloc>().state;

    // ✅ إذا كان تعديل: استخدم ID القديم، وإلا: أنشئ ID جديد
    final expenseId = widget.expenseToEdit?.id ?? const Uuid().v4();

    final expense = Expense(
      id: expenseId,
      amount: amount,
      category: _selectedCategory,
      notes: _notesController.text.trim(),
      date: _selectedDate!,
      photoPath: _selectedImagePath,
      accountId: _selectedAccountId ?? 'default',
      appMode: settings.appMode, // إضافة الوضع الحالي
      // الحقول التجارية
      projectId: settings.isBusinessMode ? _selectedProjectId : null,
      department:
          settings.isBusinessMode
              ? _departmentController.text.trim().isEmpty
                  ? null
                  : _departmentController.text.trim()
              : null,
      invoiceNumber:
          settings.isBusinessMode
              ? _invoiceNumberController.text.trim().isEmpty
                  ? null
                  : _invoiceNumberController.text.trim()
              : null,
      vendorName:
          settings.isBusinessMode
              ? _vendorNameController.text.trim().isEmpty
                  ? null
                  : _vendorNameController.text.trim()
              : null,
      employeeId: settings.isBusinessMode ? _selectedEmployeeId : null,
    );

    // ✅ إذا كان تعديل: استخدم EditExpense، وإلا: AddExpense
    if (widget.expenseToEdit != null) {
      context.read<ExpenseBloc>().add(EditExpense(expense));
    } else {
      context.read<ExpenseBloc>().add(AddExpense(expense));
    }

    Navigator.of(context).pop();
  }
}
