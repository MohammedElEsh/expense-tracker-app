// ✅ Clean Architecture - Expense Details Screen (Refactored)
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog_refactored.dart';

// Import Widgets
import 'package:expense_tracker/features/expenses/presentation/widgets/details/expense_header_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/details/expense_basic_details_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/details/expense_account_info_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/details/expense_receipt_image_card.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/details/expense_additional_info_card.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  // Local expense state that can be updated on refresh
  late Expense _currentExpense;
  String? _projectName;
  String? _vendorName;
  String? _employeeName;
  Account? _account;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    // Initialize local expense state from widget
    _currentExpense = widget.expense;
    _loadAdditionalData();
  }

  /// Refresh expense data by calling GET /api/expenses/:id
  Future<void> _refreshExpense() async {
    if (_isRefreshing) return; // Prevent duplicate calls

    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      debugPrint('🔄 Refreshing expense: ${_currentExpense.id}');

      // Call GET /api/expenses/:id to get latest expense data
      final updatedExpense = await serviceLocator.expenseApiService
          .getExpenseById(_currentExpense.id);

      debugPrint('✅ Expense refreshed: ${updatedExpense.id}');

      if (mounted) {
        // Update local expense state with new API response
        setState(() {
          _currentExpense = updatedExpense;
          _isRefreshing = false;
        });

        // Reload additional data (project, employee, account) to refresh UI
        await _loadAdditionalData();
      }
    } catch (e) {
      debugPrint('❌ Error refreshing expense: $e');
      if (mounted) {
        String errorMessage = 'Failed to refresh expense';
        if (e.toString().contains('NetworkException') ||
            e.toString().contains('SocketException')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('ServerException')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage =
              'Failed to refresh: ${e.toString().replaceAll('Exception: ', '')}';
        }

        setState(() {
          _isRefreshing = false;
          _refreshError = errorMessage;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadAdditionalData() async {
    setState(() => _isLoading = true);

    try {
      // Load project name
      if (_currentExpense.projectId != null &&
          _currentExpense.projectId!.isNotEmpty) {
        try {
          final project = await serviceLocator.projectService.getProjectById(
            _currentExpense.projectId!,
          );
          if (project != null && mounted) {
            setState(() => _projectName = project.name);
            debugPrint('✅ Loaded project name: ${project.name}');
          } else {
            debugPrint('⚠️ Project not found: ${_currentExpense.projectId}');
          }
        } catch (e) {
          debugPrint('❌ Error loading project: $e');
        }
      }

      // Load vendor name (stored directly in expense)
      if (_currentExpense.vendorName != null &&
          _currentExpense.vendorName!.isNotEmpty) {
        setState(() => _vendorName = _currentExpense.vendorName);
        debugPrint('✅ Loaded vendor name: ${_currentExpense.vendorName}');
      }

      // Load employee name from UserBloc
      if (_currentExpense.employeeId != null &&
          _currentExpense.employeeId!.isNotEmpty) {
        await _tryLoadEmployeeFromUsers();
      }

      // تحميل معلومات الحساب
      if (!mounted) return;
      final accountState = context.read<AccountBloc>().state;
      final account = accountState.getAccountById(_currentExpense.accountId);
      if (account != null && mounted) {
        setState(() => _account = account);
        debugPrint('✅ تم تحميل معلومات الحساب: ${account.name}');
      }

      // طباعة جميع البيانات الإضافية للمصروف
      debugPrint('📊 بيانات المصروف الإضافية:');
      debugPrint('   - Project ID: ${_currentExpense.projectId}');
      debugPrint('   - Vendor Name: ${_currentExpense.vendorName}');
      debugPrint('   - Employee ID: ${_currentExpense.employeeId}');
      debugPrint('   - Department: ${_currentExpense.department}');
      debugPrint('   - Invoice Number: ${_currentExpense.invoiceNumber}');
    } catch (e) {
      debugPrint('❌ خطأ في تحميل البيانات الإضافية: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final isRTL = settings.language == 'ar';
            final currentUser = userState.currentUser;

            // 🔒 التحقق من الصلاحيات
            final canEdit = _canEditExpense(currentUser, settings.appMode);
            final canDelete = _canDeleteExpense(currentUser, settings.appMode);

            return Directionality(
              textDirection:
                  isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    isRTL ? 'تفاصيل المصروف' : 'Expense Details',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    // زر القائمة
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit' && canEdit) {
                          await _editExpense(context, isRTL);
                        } else if (value == 'delete' && canDelete) {
                          await _deleteExpense(context, isRTL);
                        } else if (value == 'share') {
                          _shareExpense(isRTL);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (canEdit)
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit,color: Colors.black, size: 20),
                                    const SizedBox(width: 8),
                                    Text(isRTL ? 'تعديل' : 'Edit'),
                                  ],
                                ),
                              ),
                            if (canDelete)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isRTL ? 'حذف' : 'Delete',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            // PopupMenuItem(
                            //   value: 'share',
                            //   child: Row(
                            //     children: [
                            //       const Icon(Icons.share, size: 20),
                            //       const SizedBox(width: 8),
                            //       Text(isRTL ? 'مشاركة' : 'Share'),
                            //     ],
                            //   ),
                            // ),
                          ],
                    ),
                  ],
                ),
                body:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                          onRefresh: _refreshExpense,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Show refresh error if any
                                if (_refreshError != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red[300]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _refreshError!,
                                            style: TextStyle(
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Header - المبلغ والفئة
                                ExpenseHeaderCard(
                                  expense: _currentExpense,
                                  isRTL: isRTL,
                                  currency: settings.currency,
                                ),
                                const SizedBox(height: 24),

                                // التفاصيل الأساسية
                                ExpenseBasicDetailsCard(
                                  expense: _currentExpense,
                                  isRTL: isRTL,
                                ),
                                const SizedBox(height: 16),

                                // الحساب البنكي
                                if (_account != null) ...[
                                  ExpenseAccountInfoCard(
                                    account: _account,
                                    isRTL: isRTL,
                                    currency: settings.currency,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // صورة الإيصال
                                if (_currentExpense.photoPath != null) ...[
                                  ExpenseReceiptImageCard(
                                    expense: _currentExpense,
                                    isRTL: isRTL,
                                    onViewFullImage: _viewFullImage,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // معلومات إضافية (تشمل التفاصيل التجارية)
                                ExpenseAdditionalInfoCard(
                                  expense: _currentExpense,
                                  isRTL: isRTL,
                                  employeeName: _employeeName,
                                  projectName: _projectName,
                                  vendorName: _vendorName,
                                ),
                              ],
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

  // 🔒 التحقق من صلاحية التعديل
  bool _canEditExpense(User? currentUser, AppMode appMode) {
    if (currentUser == null) {
      debugPrint('🔒 canEdit: false - currentUser is null');
      return false;
    }

    final currentUserId = currentUser.id;
    if (currentUserId.isEmpty) {
      debugPrint('🔒 canEdit: false - currentUserId is empty');
      return false;
    }

    debugPrint('🔒 Checking edit permission:');
    debugPrint('   - Current User: $currentUserId');
    debugPrint('   - Expense employeeId: ${_currentExpense.employeeId}');
    debugPrint('   - App Mode: $appMode');
    debugPrint('   - User Role: ${currentUser.role}');

    if (appMode == AppMode.personal) {
      // في الوضع الشخصي: فقط صاحب المصروف
      // نستخدم employeeId إذا كان موجود، وإلا نفترض أنه صاحبه
      final canEdit =
          _currentExpense.employeeId == null ||
          _currentExpense.employeeId == currentUserId;
      debugPrint('🔒 Personal mode - canEdit: $canEdit');
      return canEdit;
    } else {
      // في الوضع التجاري
      if (currentUser.role == UserRole.owner) {
        // المدير يستطيع تعديل كل المصروفات
        debugPrint('🔒 Business mode - Owner - canEdit: true');
        return true;
      } else {
        // الموظف يستطيع تعديل مصروفاته فقط
        final canEdit = _currentExpense.employeeId == currentUserId;
        debugPrint('🔒 Business mode - Employee - canEdit: $canEdit');
        return canEdit;
      }
    }
  }

  // 🔒 التحقق من صلاحية الحذف
  bool _canDeleteExpense(User? currentUser, AppMode appMode) {
    if (currentUser == null) return false;

    final currentUserId = currentUser.id;
    if (currentUserId.isEmpty) return false;

    if (appMode == AppMode.personal) {
      // في الوضع الشخصي: فقط صاحب المصروف
      // نستخدم employeeId إذا كان موجود، وإلا نفترض أنه صاحبه
      return _currentExpense.employeeId == null ||
          _currentExpense.employeeId == currentUserId;
    } else {
      // في الوضع التجاري: فقط المدير
      return currentUser.role == UserRole.owner;
    }
  }

  Future<void> _editExpense(BuildContext context, bool isRTL) async {
    // Navigate to edit screen and wait for result
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder:
            (context) => AddExpenseDialogRefactored(
              selectedDate: _currentExpense.date,
              expenseToEdit: _currentExpense,
            ),
      ),
    );

    // Reload expense details and refresh list after successful edit
    if (mounted && result != null) {
      // Refresh expense data from API
      await _refreshExpense();

      // Refresh expenses list
      context.read<ExpenseBloc>().add(const LoadExpenses());
    }
  }

  Future<void> _deleteExpense(BuildContext context, bool isRTL) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'حذف المصروف' : 'Delete Expense'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من حذف هذا المصروف؟ لا يمكن التراجع عن هذا الإجراء.'
                  : 'Are you sure you want to delete this expense? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRTL ? 'حذف' : 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        // Delete expense via BLoC
        context.read<ExpenseBloc>().add(DeleteExpense(_currentExpense.id));

        // Navigate back to expenses list
        if (mounted) {
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isRTL
                        ? 'تم حذف المصروف بنجاح'
                        : 'Expense deleted successfully',
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'حدث خطأ أثناء حذف المصروف' : 'Error deleting expense',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareExpense(bool isRTL) {
    final categoryName = _currentExpense.category;
    final text = '''
${isRTL ? 'تفاصيل المصروف' : 'Expense Details'}:
${isRTL ? 'المبلغ' : 'Amount'}: ${_currentExpense.amount}
${isRTL ? 'الفئة' : 'Category'}: $categoryName
${isRTL ? 'الملاحظات' : 'Notes'}: ${_currentExpense.notes}
${isRTL ? 'التاريخ' : 'Date'}: ${DateFormat('dd/MM/yyyy').format(_currentExpense.date)}
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isRTL ? 'جاري المشاركة...' : 'Sharing...')),
    );
    debugPrint('Share text: $text');
  }

  void _viewFullImage() {
    if (_currentExpense.photoPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  child: Image.file(File(_currentExpense.photoPath!)),
                ),
              ),
            ),
      ),
    );
  }

  /// محاولة تحميل الموظف من users collection مباشرة
  Future<void> _tryLoadEmployeeFromUsers() async {
    if (_currentExpense.employeeId != null &&
        _currentExpense.employeeId!.isNotEmpty) {
      try {
        // جرب البحث في users collection مباشرة
        if (!mounted) return;
        final userState = context.read<UserBloc>().state;
        if (userState.users.isNotEmpty) {
          final employee = userState.users.firstWhere(
            (user) => user.id == _currentExpense.employeeId,
            orElse: () => throw StateError('User not found'),
          );
          if (mounted) {
            setState(() => _employeeName = employee.name);
            debugPrint('✅ تم تحميل اسم الموظف من UserBloc: ${employee.name}');
          }
        }
      } catch (e) {
        debugPrint('❌ لم يتم العثور على الموظف في UserBloc: $e');
      }
    }
  }
}
