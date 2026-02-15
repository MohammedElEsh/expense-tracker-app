// ✅ Home Feature - Presentation Layer - Home Screen (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_cubit.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_state.dart';
import 'package:expense_tracker/features/home/presentation/widgets/home_app_bar.dart';
import 'package:expense_tracker/features/home/presentation/widgets/home_summary_card.dart';
import 'package:expense_tracker/features/home/presentation/widgets/home_expense_list.dart';
import 'package:expense_tracker/features/home/presentation/widgets/view_mode_selector.dart';
import 'package:expense_tracker/features/home/presentation/widgets/home_logout_dialog.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart' as project_data;
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/search_filter_widget.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:expense_tracker/app/widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  /// Search-filtered list; used only when isSearchVisible is true.
  List<Expense> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // تسجيل الخروج (من AppBar - يعرض dialog)
  Future<void> _handleLogout(bool isRTL, BuildContext homeContext) async {
    // عرض dialog التأكيد
    final confirmed = await HomeLogoutDialog.show(context, isRTL: isRTL);

    if (confirmed == true && mounted) {
      // ignore: use_build_context_synchronously
      _performLogout(homeContext);
    }
  }

  /// Logout: only trigger HomeCubit; navigation on success is done in BlocListener.
  void _performLogout(BuildContext homeContext) {
    homeContext.read<HomeCubit>().logout();
  }

  // فتح dialog إضافة مصروف
  void _handleAddExpense(HomeState homeState, AccountState accountState) {
    // التحقق من وجود حسابات
    if (accountState.accounts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<SettingsCubit>().state.language == 'ar'
                  ? 'يجب إضافة حساب أولاً'
                  : 'Please add an account first',
            ),
            action: SnackBarAction(
              label:
                  context.read<SettingsCubit>().state.language == 'ar'
                      ? 'إضافة'
                      : 'Add',
              onPressed: () {
                context.push(AppRoutes.accounts);
              },
            ),
          ),
        );
      }
      return;
    }

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

    showDialog<void>(
      context: context,
      builder: (ctx) => AddExpenseDialog.createWithCubit(
        ctx,
        selectedDate: homeState.selectedDate,
        projects: projects,
        vendorNames: vendorNames,
      ),
    );
  }

  // عرض selector وضع العرض
  void _showViewModeSelector(
    bool isRTL,
    String currentViewMode,
    BuildContext homeContext,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ViewModeSelector(
            isRTL: isRTL,
            currentViewMode: currentViewMode,
            onViewModeChanged: (newMode) {
              // استخدام homeContext بدلاً من context الـ BottomSheet
              homeContext.read<HomeCubit>().changeViewMode(newMode);
            },
          ),
    );
  }

  // الحصول على عنوان وضع العرض
  String _getViewModeTitle(bool isRTL, String viewMode, DateTime selectedDate) {
    switch (viewMode) {
      case 'day':
        return isRTL
            ? 'اليوم: ${DateFormat('dd MMMM yyyy', 'ar').format(selectedDate)}'
            : 'Today: ${DateFormat('MMM dd, yyyy').format(selectedDate)}';
      case 'week':
        final weekStart = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );
        final weekEnd = weekStart.add(const Duration(days: 6));
        return isRTL
            ? 'الأسبوع: ${DateFormat('dd MMM', 'ar').format(weekStart)} - ${DateFormat('dd MMM', 'ar').format(weekEnd)}'
            : 'Week: ${DateFormat('MMM dd').format(weekStart)} - ${DateFormat('MMM dd').format(weekEnd)}';
      case 'month':
        return isRTL
            ? 'الشهر: ${DateFormat('MMMM yyyy', 'ar').format(selectedDate)}'
            : 'Month: ${DateFormat('MMMM yyyy').format(selectedDate)}';
      case 'all':
        return isRTL ? 'جميع المصروفات' : 'All Expenses';
      default:
        return isRTL ? 'جميع المصروفات' : 'All Expenses';
    }
  }

  // الحصول على label وضع العرض
  String _getViewModeLabel(bool isRTL, String viewMode) {
    switch (viewMode) {
      case 'day':
        return isRTL ? 'اليوم' : 'Day';
      case 'week':
        return isRTL ? 'الأسبوع' : 'Week';
      case 'month':
        return isRTL ? 'الشهر' : 'Month';
      case 'all':
        return isRTL ? 'الكل' : 'All';
      default:
        return isRTL ? 'الكل' : 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>(),
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (prev, curr) =>
            prev.isLoggingOut && !curr.isLoggingOut && curr.logoutError == null,
        listener: (context, state) {
          if (!mounted) return;
          context.go(AppRoutes.login);
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              return BlocBuilder<ExpenseCubit, ExpenseState>(
                builder: (context, expenseState) {
                  return BlocBuilder<UserCubit, UserState>(
                    builder: (context, userState) {
                      return BlocBuilder<AccountCubit, AccountState>(
                        builder: (context, accountState) {
                          final isRTL = settings.language == 'ar';
                          final isTablet =
                              MediaQuery.of(context).size.width > 600;
                          final isDesktop = context.isDesktop;
                          final currentUser = userState is UserLoaded
                              ? userState.currentUser
                              : null;

                          // Only owner role should filter by selected account
                          // All other roles (accountant, employee, auditor) should see all expenses
                          // returned by the API regardless of account selection.
                          // The backend already handles role-based filtering:
                          // - Owner/Accountant: All company expenses
                          // - Employee: Only their own expenses (where employeeId matches)
                          // - Auditor: Read-only access to all expenses
                          final canFilterByAccount =
                              currentUser != null &&
                              currentUser.role == UserRole.owner;

                          // Get selectedAccountId for filtering (only if filtering is enabled)
                          // Force to null if filtering is disabled (show all accounts)
                          final selectedAccountId =
                              canFilterByAccount
                                  ? accountState.selectedAccount?.id
                                  : null;

                          // Only filter by account if:
                          // 1. User is owner (can filter)
                          // 2. Account is explicitly selected (not auto-selected)
                          // 3. Selected account has expenses (prevent empty list)
                          final shouldFilterByAccount =
                              canFilterByAccount &&
                              selectedAccountId != null &&
                              expenseState.allExpenses.any(
                                (e) => e.accountId == selectedAccountId,
                              );

                          debugPrint(
                            '🏠 HomeScreen - User role: ${currentUser?.role.name ?? "null"}',
                          );
                          debugPrint(
                            '🏠 HomeScreen - Can filter by account: $canFilterByAccount',
                          );
                          debugPrint(
                            '🏠 HomeScreen - Should filter by account: $shouldFilterByAccount',
                          );
                          debugPrint(
                            '🏠 HomeScreen - Selected account: ${selectedAccountId ?? "null"}',
                          );
                          debugPrint(
                            '🏠 HomeScreen - Total expenses from API: ${expenseState.allExpenses.length}',
                          );
                          if (expenseState.isMutating) {
                            debugPrint(
                              '🔄 HomeScreen - isMutating: true (optimistic update in progress)',
                            );
                          }

                          // HomeCubit runs filter and total use cases; only emits when result changes
                          context.read<HomeCubit>().updateDisplayData(
                                expenseState.allExpenses,
                                accountId:
                                    shouldFilterByAccount
                                        ? selectedAccountId
                                        : null,
                              );

                          final displayExpenses = homeState.filteredExpenses;
                          final totalAmount = homeState.totalAmount;

                          debugPrint(
                            '🏠 HomeScreen - Display expenses after filtering: ${displayExpenses.length}',
                          );

                          // Use search-filtered list when search is visible, else view-mode filtered
                          final finalDisplayExpenses =
                              homeState.isSearchVisible
                                  ? filteredExpenses
                                  : displayExpenses;

                          debugPrint(
                            '🏠 HomeScreen (Refactored) - Final display expenses: ${finalDisplayExpenses.length}',
                          );
                          debugPrint(
                            '🏠 HomeScreen (Refactored) - Is search visible: ${homeState.isSearchVisible}',
                          );
                          if (finalDisplayExpenses.isEmpty &&
                              expenseState.allExpenses.isNotEmpty) {
                            debugPrint(
                              '⚠️ WARNING: Expenses exist but none displayed!',
                            );
                            debugPrint(
                              '   - All expenses: ${expenseState.allExpenses.length}',
                            );
                            debugPrint(
                              '   - Display expenses: ${displayExpenses.length}',
                            );
                            debugPrint(
                              '   - Filtered expenses: ${filteredExpenses.length}',
                            );
                            debugPrint('   - View mode: ${homeState.viewMode}');
                            debugPrint(
                              '   - Should filter by account: $shouldFilterByAccount',
                            );
                          }

                          return Directionality(
                            textDirection:
                                isRTL
                                    ? ui.TextDirection.rtl
                                    : ui.TextDirection.ltr,
                            child: Scaffold(
                              drawer: AppDrawer(
                                onLogout: () => _performLogout(context),
                              ),
                              appBar: HomeAppBar(
                                isRTL: isRTL,
                                isDesktop: isDesktop,
                                isTablet: isTablet,
                                appMode: settings.appMode,
                                currentUser: currentUser,
                                onLogout: () => _handleLogout(isRTL, context),
                                onSearch: () {
                                  context
                                      .read<HomeCubit>()
                                      .toggleSearchVisibility();
                                },
                              ),
                              body: Column(
                                children: [
                                  // Search and Filter Widget
                                  if (homeState.isSearchVisible)
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: SearchFilterWidget(
                                          // Use key to force recreation when account changes
                                          key: ValueKey<String?>(
                                            accountState.selectedAccount?.id,
                                          ),
                                          // Filter expenses by selected account only for owner role
                                          // All other roles see all expenses returned by API
                                          expenses:
                                              (accountState.selectedAccount !=
                                                          null &&
                                                      shouldFilterByAccount)
                                                  ? expenseState.allExpenses
                                                      .where(
                                                        (expense) =>
                                                            expense.accountId ==
                                                            accountState
                                                                .selectedAccount!
                                                                .id,
                                                      )
                                                      .toList()
                                                  : expenseState.allExpenses,
                                          onFilteredExpenses: (filtered) {
                                            setState(() {
                                              filteredExpenses = filtered;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                  // Date and Summary Card (only show when not searching)
                                  if (!homeState.isSearchVisible)
                                    HomeSummaryCard(
                                      isRTL: isRTL,
                                      isDesktop: isDesktop,
                                      isTablet: isTablet,
                                      isDarkMode: settings.isDarkMode,
                                      viewModeTitle: _getViewModeTitle(
                                        isRTL,
                                        homeState.viewMode,
                                        homeState.selectedDate,
                                      ),
                                      viewModeLabel: _getViewModeLabel(
                                        isRTL,
                                        homeState.viewMode,
                                      ),
                                      totalAmount: totalAmount,
                                      transactionCount:
                                          finalDisplayExpenses.length,
                                      currencySymbol: settings.currencySymbol,
                                      primaryColor: settings.primaryColor,
                                      onViewModeTap:
                                          () => _showViewModeSelector(
                                            isRTL,
                                            homeState.viewMode,
                                            context,
                                          ),
                                      fadeAnimation: _fadeAnimation,
                                      slideAnimation: _slideAnimation,
                                    ),

                                  // Inline loader for mutations (add/delete)
                                  if (expenseState.isMutating)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.xs,
                                        horizontal: AppSpacing.md,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: AppSpacing.md,
                                            height: AppSpacing.md,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            isRTL
                                                ? 'جاري المعالجة...'
                                                : 'Processing...',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Expense List
                                  HomeExpenseList(
                                    expenses: finalDisplayExpenses,
                                    isRTL: isRTL,
                                    isDesktop: isDesktop,
                                    isTablet: isTablet,
                                    currencySymbol: settings.currencySymbol,
                                    onDelete: (expense) {
                                      // Delete expense logic
                                      context
                                          .read<ExpenseCubit>()
                                          .deleteExpense(expense.id);
                                    },
                                    onRefresh: () async {
                                      // Refresh expenses - use RefreshExpenses to always fetch
                                      final expenseCubit =
                                          context.read<ExpenseCubit>();
                                      expenseCubit.refreshExpenses();

                                      // Wait for the bloc to finish refreshing
                                      await expenseCubit.stream.firstWhere(
                                        (state) => !state.isRefreshing,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              floatingActionButton: FloatingActionButton(
                                heroTag:
                                    'home_add_expense_fab', // ✅ Unique hero tag
                                onPressed:
                                    () => _handleAddExpense(
                                      homeState,
                                      accountState,
                                    ),
                                child: const Icon(Icons.add),
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
        },
      ),
      ),
    );
  }
}
