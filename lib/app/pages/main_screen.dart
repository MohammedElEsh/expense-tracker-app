import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart' as router;
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/users/domain/utils/permission_service.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const MainScreen({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isInitializing = true;

  String? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند بدء الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentUser();
    });
  }

  /// Load data for current user. Bootstraps from API when in shell with valid token but no user in cubit (cold start).
  void _loadDataForCurrentUser() {
    final state = context.read<UserCubit>().state;
    final currentUser = state is UserLoaded ? state.currentUser : null;

    if (currentUser != null && _lastLoadedUserId != currentUser.id) {
      debugPrint(
        '🔄 User changed - Loading data for user: ${currentUser.id} (role: ${currentUser.role.name})',
      );
      context.read<AccountCubit>().initializeAccounts();
      context.read<ExpenseCubit>().loadExpenses(forceRefresh: true);
      context.read<BudgetCubit>().loadBudgets();
      context.read<RecurringExpenseCubit>().loadRecurringExpenses();
      _lastLoadedUserId = currentUser.id;
    } else if (currentUser == null && _lastLoadedUserId != null) {
      _lastLoadedUserId = null;
    } else if (currentUser == null) {
      _bootstrapUserFromToken();
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isInitializing = false);
    });
  }

  Future<void> _bootstrapUserFromToken() async {
    final token = await getIt<PrefHelper>().getAuthToken();
    if (token == null || token.isEmpty || !mounted) return;
    try {
      final user = await getIt<AuthRemoteDataSource>().getCurrentUser();
      final appContext = getIt<AppContext>();
      if (user.accountType == 'business') {
        await appContext.setAppMode(AppMode.business);
        if (user.companyId != null) await appContext.setCompanyId(user.companyId);
      } else {
        await appContext.setAppMode(AppMode.personal);
        await appContext.setCompanyId(null);
      }
      if (!mounted) return;
      final roleStr = (user.role ?? 'owner').toLowerCase();
      final userRole = UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.owner,
      );
      await userContextManager.onUserContextChanged(
        userId: user.id,
        role: userRole,
        companyId: user.companyId,
        context: context,
      );
      if (!mounted) return;
      final entity = UserEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        role: userRole,
        isActive: user.isActive,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLogin,
        phone: user.phone,
      );
      context.read<UserCubit>().setCurrentUser(entity);
      context.read<SettingsCubit>().loadSettings(forceReload: true);
      context.read<AccountCubit>().initializeAccounts();
      context.read<ExpenseCubit>().loadExpenses(forceRefresh: true);
      final now = DateTime.now();
      context.read<BudgetCubit>().loadBudgetsForMonth(now.year, now.month);
      context.read<RecurringExpenseCubit>().loadRecurringExpenses();
      context.read<UserCubit>().loadUsers();
    } catch (_) {}
    if (mounted) setState(() => _isInitializing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, currentState) {
        // Only reload expenses when app mode changes (not on every settings change)
        // This prevents unnecessary API calls on settings updates
        // Note: ReloadExpensesForCurrentMode already handles mode-specific filtering
        // If needed, compare previous mode with current mode to avoid duplicate calls
      },
      child: BlocListener<UserCubit, UserState>(
        listener: (context, userState) {
          // Reload data when user changes (login/logout/role switch)
          _loadDataForCurrentUser();
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                final currentUser = userState is UserLoaded ? userState.currentUser : null;
                if (currentUser == null && _isInitializing) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final isRTL = settings.language == 'ar';
                final budgetAvailable =
                    settings.appMode == AppMode.personal ||
                    (settings.appMode == AppMode.business &&
                        currentUser != null &&
                        PermissionService.canManageBudgetsEntity(currentUser));

                final adjustedIndex = _indexFromPath(widget.currentLocation, budgetAvailable);

                final bottomNavItems = <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: isRTL ? 'الرئيسية' : 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.analytics),
                    label: isRTL ? 'الإحصائيات' : 'Statistics',
                  ),
                  if (budgetAvailable)
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.account_balance_wallet),
                      label: isRTL ? 'الميزانية' : 'Budget',
                    ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: isRTL ? 'الإعدادات' : 'Settings',
                  ),
                ];

                final isDesktop = ResponsiveUtils.isDesktop(context);

                return PopScope(
                  canPop: adjustedIndex == 0,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop && adjustedIndex != 0) {
                      context.go(router.AppRoutes.home);
                    }
                  },
                  child: isDesktop
                      ? _buildDesktopLayout(
                          adjustedIndex,
                          isRTL,
                          currentUser,
                          settings.appMode,
                          budgetAvailable,
                        )
                      : _buildMobileLayout(
                          bottomNavItems,
                          adjustedIndex,
                          currentUser,
                          settings.appMode,
                          budgetAvailable,
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  int _indexFromPath(String path, bool budgetAvailable) {
    switch (path) {
      case router.AppRoutes.home:
        return 0;
      case router.AppRoutes.statistics:
        return 1;
      case router.AppRoutes.budgets:
        return budgetAvailable ? 2 : 1;
      case router.AppRoutes.settings:
        return budgetAvailable ? 3 : 2;
      default:
        return 0;
    }
  }

  void _onTabSelected(int adjustedIndex, bool budgetAvailable) {
    if (adjustedIndex == 0) {
      context.go(router.AppRoutes.home);
    } else if (adjustedIndex == 1) {
      context.go(router.AppRoutes.statistics);
    } else if (budgetAvailable && adjustedIndex == 2) {
      context.go(router.AppRoutes.budgets);
    } else {
      context.go(router.AppRoutes.settings);
    }
  }

  /// 🖥️ Desktop Layout with NavigationRail
  Widget _buildDesktopLayout(
    int adjustedIndex,
    bool isRTL,
    UserEntity? currentUser,
    AppMode appMode,
    bool budgetAvailable,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: adjustedIndex,
            onDestinationSelected: (index) => _onTabSelected(index, budgetAvailable),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text(isRTL ? 'الرئيسية' : 'Home'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.analytics_outlined),
                selectedIcon: const Icon(Icons.analytics),
                label: Text(isRTL ? 'الإحصائيات' : 'Statistics'),
              ),
              if (budgetAvailable)
                NavigationRailDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet),
                  label: Text(isRTL ? 'الميزانية' : 'Budget'),
                ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(isRTL ? 'الإعدادات' : 'Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Mobile/Tablet Layout with BottomNavigationBar
  Widget _buildMobileLayout(
    List<BottomNavigationBarItem> bottomNavItems,
    int adjustedIndex,
    UserEntity? currentUser,
    AppMode appMode,
    bool budgetAvailable,
  ) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: adjustedIndex,
          onTap: (index) => _onTabSelected(index, budgetAvailable),
          type: BottomNavigationBarType.fixed,
          items: bottomNavItems,
        ),
      ),
    );
  }
}
