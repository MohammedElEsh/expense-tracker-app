// ✅ Clean Architecture - Expense Details Screen (Refactored)
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_detail_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_detail_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart' as project_data;
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';

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
  String? _projectName;
  String? _vendorName;
  String? _employeeName;
  Account? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAdditionalData(context, widget.expense);
    });
  }

  /// Refresh expense via Cubit (no direct API/service calls from UI).
  Future<void> _refreshExpense() async {
    await context.read<ExpenseDetailCubit>().refreshExpense();
    if (!mounted) return;
    final expense = context.read<ExpenseDetailCubit>().state.expense;
    if (expense != null) await _loadAdditionalData(context, expense);
  }

  Future<void> _loadAdditionalData(BuildContext context, Expense expense) async {
    setState(() => _isLoading = true);

    try {
      if (expense.projectId != null && expense.projectId!.isNotEmpty) {
        try {
          final project = await context.read<ProjectCubit>().getProjectById(
            expense.projectId!,
          );
          if (project != null && mounted) {
            setState(() => _projectName = project.name);
            debugPrint('✅ Loaded project name: ${project.name}');
          } else {
            debugPrint('⚠️ Project not found: ${expense.projectId}');
          }
        } catch (e) {
          debugPrint('❌ Error loading project: $e');
        }
      }

      if (expense.vendorName != null && expense.vendorName!.isNotEmpty) {
        setState(() => _vendorName = expense.vendorName);
        debugPrint('✅ Loaded vendor name: ${expense.vendorName}');
      }

      if (expense.employeeId != null && expense.employeeId!.isNotEmpty) {
        await _tryLoadEmployeeFromUsers(context, expense.employeeId!);
      }

      if (!mounted) return;
      final accountState = context.read<AccountCubit>().state;
      final account = accountState.getAccountById(expense.accountId);
      if (account != null && mounted) {
        setState(() => _account = account);
        debugPrint('✅ تم تحميل معلومات الحساب: ${account.name}');
      }

      debugPrint('📊 بيانات المصروف الإضافية:');
      debugPrint('   - Project ID: ${expense.projectId}');
      debugPrint('   - Vendor Name: ${expense.vendorName}');
      debugPrint('   - Employee ID: ${expense.employeeId}');
      debugPrint('   - Department: ${expense.department}');
      debugPrint('   - Invoice Number: ${expense.invoiceNumber}');
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
    return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              return BlocBuilder<ExpenseDetailCubit, ExpenseDetailState>(
                builder: (context, detailState) {
                  final expense = detailState.expense ?? widget.expense;
                  final isRTL = settings.language == 'ar';
                  final currentUser = userState is UserLoaded ? userState.currentUser : null;

                  // 🔒 التحقق من الصلاحيات
                  final canEdit = _canEditExpense(currentUser, settings.appMode, expense);
                  final canDelete = _canDeleteExpense(currentUser, settings.appMode, expense);

                  return Directionality(
              textDirection:
                  isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    isRTL ? 'تفاصيل المصروف' : 'Expense Details',
                    style: AppTypography.headlineSmall,
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
                          _shareExpense(context, isRTL);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (canEdit)
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                      size: AppSpacing.iconSm,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(isRTL ? 'تعديل' : 'Edit'),
                                  ],
                                ),
                              ),
                            if (canDelete)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                      size: AppSpacing.iconSm,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      isRTL ? 'حذف' : 'Delete',
                                      style: TextStyle(color: AppColors.error),
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
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Show refresh error if any
                                    if (detailState.error != null)
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: AppSpacing.md,
                                        ),
                                        padding: const EdgeInsets.all(
                                          AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.errorLight,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusSm,
                                          ),
                                          border: Border.all(
                                            color: AppColors.error.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: AppColors.error,
                                              size: AppSpacing.iconSm,
                                            ),
                                            const SizedBox(width: AppSpacing.xs),
                                            Expanded(
                                              child: Text(
                                                detailState.error!,
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                      color: AppColors.error,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Header - المبلغ والفئة
                                    ExpenseHeaderCard(
                                      expense: expense,
                                      isRTL: isRTL,
                                      currency: settings.currency,
                                    ),
                                    const SizedBox(height: AppSpacing.xl),

                                    // التفاصيل الأساسية
                                    ExpenseBasicDetailsCard(
                                      expense: expense,
                                      isRTL: isRTL,
                                    ),
                                    const SizedBox(height: AppSpacing.md),

                                    // الحساب البنكي
                                    if (_account != null) ...[
                                      ExpenseAccountInfoCard(
                                        account: _account,
                                        isRTL: isRTL,
                                        currency: settings.currency,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                    ],

                                    // صورة الإيصال
                                    if (expense.photoPath != null) ...[
                                      ExpenseReceiptImageCard(
                                        expense: expense,
                                        isRTL: isRTL,
                                        onViewFullImage: () => _viewFullImage(context),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                    ],

                                    // معلومات إضافية (تشمل التفاصيل التجارية)
                                    ExpenseAdditionalInfoCard(
                                      expense: expense,
                                      isRTL: isRTL,
                                      employeeName: _employeeName,
                                      projectName: _projectName,
                                      vendorName: _vendorName,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
  }

  // 🔒 التحقق من صلاحية التعديل
  bool _canEditExpense(UserEntity? currentUser, AppMode appMode, Expense expense) {
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
    debugPrint('   - Expense employeeId: ${expense.employeeId}');
    debugPrint('   - App Mode: $appMode');
    debugPrint('   - User Role: ${currentUser.role}');

    if (appMode == AppMode.personal) {
      final canEdit =
          expense.employeeId == null || expense.employeeId == currentUserId;
      debugPrint('🔒 Personal mode - canEdit: $canEdit');
      return canEdit;
    } else {
      if (currentUser.role == UserRole.owner) {
        debugPrint('🔒 Business mode - Owner - canEdit: true');
        return true;
      } else {
        final canEdit = expense.employeeId == currentUserId;
        debugPrint('🔒 Business mode - Employee - canEdit: $canEdit');
        return canEdit;
      }
    }
  }

  // 🔒 التحقق من صلاحية الحذف
  bool _canDeleteExpense(UserEntity? currentUser, AppMode appMode, Expense expense) {
    if (currentUser == null) return false;

    final currentUserId = currentUser.id;
    if (currentUserId.isEmpty) return false;

    if (appMode == AppMode.personal) {
      return expense.employeeId == null || expense.employeeId == currentUserId;
    } else {
      return currentUser.role == UserRole.owner;
    }
  }

  Future<void> _editExpense(BuildContext context, bool isRTL) async {
    final expense = context.read<ExpenseDetailCubit>().state.expense ?? widget.expense;
    final projectCubit = context.read<ProjectCubit>();
    final vendorCubit = context.read<VendorCubit>();
    final projectState = projectCubit.state;
    final projectEntities = projectState is ProjectLoaded
        ? projectState.projects
            .where((p) =>
                p.status != ProjectStatus.cancelled &&
                p.status != ProjectStatus.completed)
            .toList()
        : <ProjectEntity>[];
    final projects = projectEntities
        .map((p) => project_data.Project(
              id: p.id,
              name: p.name,
              description: p.description,
              status: project_data.ProjectStatus.values.firstWhere(
                (s) => s.name == p.status.name,
                orElse: () => project_data.ProjectStatus.planning,
              ),
              startDate: p.startDate,
              endDate: p.endDate,
              budget: p.budget,
              spentAmount: p.spentAmount,
              managerName: p.managerName,
              clientName: p.clientName,
              priority: p.priority,
              createdAt: p.createdAt,
              updatedAt: p.updatedAt,
            ))
        .toList();
    final vendorState = vendorCubit.state;
    final vendorNames = vendorState is VendorLoaded
        ? vendorState.vendors.map((v) => v.name).toList()
        : <String>[];
    final result = await showDialog<Expense>(
      context: context,
      builder: (ctx) => AddExpenseDialog.createWithCubit(
        ctx,
        selectedDate: expense.date,
        expenseToEdit: expense,
        projects: projects,
        vendorNames: vendorNames,
      ),
    );

    // Reload expense details and refresh list after successful edit
    if (mounted && result != null) {
      // Refresh expense data from API
      await _refreshExpense();

      // Refresh expenses list
      context.read<ExpenseCubit>().loadExpenses();
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
                onPressed: () => context.pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRTL ? 'حذف' : 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        final expense = context.read<ExpenseDetailCubit>().state.expense ?? widget.expense;
        context.read<ExpenseCubit>().deleteExpense(expense.id);

        // Navigate back to expenses list
        if (mounted) {
          context.pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isRTL
                        ? 'تم حذف المصروف بنجاح'
                        : 'Expense deleted successfully',
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
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
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _shareExpense(BuildContext context, bool isRTL) {
    final expense = context.read<ExpenseDetailCubit>().state.expense ?? widget.expense;
    final categoryName = expense.category;
    final text = '''
${isRTL ? 'تفاصيل المصروف' : 'Expense Details'}:
${isRTL ? 'المبلغ' : 'Amount'}: ${expense.amount}
${isRTL ? 'الفئة' : 'Category'}: $categoryName
${isRTL ? 'الملاحظات' : 'Notes'}: ${expense.notes}
${isRTL ? 'التاريخ' : 'Date'}: ${DateFormat('dd/MM/yyyy').format(expense.date)}
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isRTL ? 'جاري المشاركة...' : 'Sharing...')),
    );
    debugPrint('Share text: $text');
  }

  void _viewFullImage(BuildContext context) {
    final expense = context.read<ExpenseDetailCubit>().state.expense ?? widget.expense;
    if (expense.photoPath == null) return;

    showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ctx.pop(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(File(expense.photoPath!)),
          ),
        ),
      ),
    );
  }

  /// محاولة تحميل الموظف من users collection مباشرة
  Future<void> _tryLoadEmployeeFromUsers(BuildContext context, String employeeId) async {
    try {
      if (!mounted) return;
      final userState = context.read<UserCubit>().state;
      if (userState is UserLoaded && userState.users.isNotEmpty) {
        final employee = userState.users.firstWhere(
          (user) => user.id == employeeId,
          orElse: () => throw StateError('User not found'),
        );
        if (mounted) {
          setState(() => _employeeName = employee.name);
          debugPrint('✅ تم تحميل اسم الموظف من UserCubit: ${employee.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ لم يتم العثور على الموظف في UserCubit: $e');
    }
  }
}
