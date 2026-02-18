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
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initUser();
    });
  }

  Future<void> _initUser() async {
    final userState = context.read<UserCubit>().state;

    if (userState is UserLoaded) {
      _loadUserData();
      _initializing = false;
      if (mounted) setState(() {});
      return;
    }

    final token = await getIt<PrefHelper>().getAuthToken();
    if (token == null || token.isEmpty || !mounted) {
      _initializing = false;
      setState(() {});
      return;
    }

    try {
      final user = await getIt<AuthRemoteDataSource>().getCurrentUser();
      final appContext = getIt<AppContext>();

      if (user.accountType == 'business') {
        await appContext.setAppMode(AppMode.business);
        await appContext.setCompanyId(user.companyId);
      } else {
        await appContext.setAppMode(AppMode.personal);
        await appContext.setCompanyId(null);
      }

      final role = UserRole.values.firstWhere(
        (r) => r.name == (user.role ?? 'owner'),
        orElse: () => UserRole.owner,
      );

      await userContextManager.onUserContextChanged(
        userId: user.id,
        role: role,
        companyId: user.companyId,
        context: context,
      );

      context.read<UserCubit>().setCurrentUser(
        UserEntity(
          id: user.id,
          name: user.name,
          email: user.email,
          role: role,
          isActive: user.isActive,
          createdAt: user.createdAt,
          lastLoginAt: user.lastLogin,
          phone: user.phone,
        ),
      );

      context.read<SettingsCubit>().loadSettings(forceReload: true);
      _loadUserData();
    } catch (_) {}

    _initializing = false;
    if (mounted) setState(() {});
  }

  void _loadUserData() {
    context.read<AccountCubit>().initializeAccounts();
    context.read<ExpenseCubit>().loadExpenses(forceRefresh: true);
    context.read<BudgetCubit>().loadBudgets();
    context.read<RecurringExpenseCubit>().loadRecurringExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        if (_initializing || userState is! UserLoaded) {
          return const _LoadingScreen();
        }

        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            final user = userState.currentUser;

            final budgetAvailable =
                settings.appMode == AppMode.personal ||
                (settings.appMode == AppMode.business &&
                    PermissionService.canManageBudgetsEntity(user));

            final currentIndex = _indexFromPath(
              widget.currentLocation,
              budgetAvailable,
            );

            final items = _navItems(
              isRTL: settings.language == 'ar',
              budgetAvailable: budgetAvailable,
            );

            return PopScope(
              canPop: currentIndex == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && currentIndex != 0) {
                  context.go(router.AppRoutes.home);
                }
              },
              child: Scaffold(
                body: widget.child,
                bottomNavigationBar: _AnimatedBottomNav(
                  items: items,
                  currentIndex: currentIndex,
                  onTap: (i) => _onTap(i, budgetAvailable),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _indexFromPath(String path, bool budgetAvailable) {
    return switch (path) {
      router.AppRoutes.home => 0,
      router.AppRoutes.statistics => 1,
      router.AppRoutes.budgets => budgetAvailable ? 2 : 1,
      router.AppRoutes.settings => budgetAvailable ? 3 : 2,
      _ => 0,
    };
  }

  void _onTap(int index, bool budgetAvailable) {
    if (index == 0) context.go(router.AppRoutes.home);
    if (index == 1) context.go(router.AppRoutes.statistics);
    if (index == 2 && budgetAvailable) context.go(router.AppRoutes.budgets);
    if (index == 3 || (!budgetAvailable && index == 2)) {
      context.go(router.AppRoutes.settings);
    }
  }

  List<_NavItem> _navItems({
    required bool isRTL,
    required bool budgetAvailable,
  }) {
    final items = <_NavItem>[
      _NavItem(Icons.home, isRTL ? 'الرئيسية' : 'Home'),
      _NavItem(Icons.analytics, isRTL ? 'إحصائيات' : 'Stats'),
    ];

    if (budgetAvailable) {
      items.add(
        _NavItem(Icons.account_balance_wallet, isRTL ? 'الميزانية' : 'Budget'),
      );
    }

    items.add(_NavItem(Icons.settings, isRTL ? 'الإعدادات' : 'Settings'));

    return items;
  }
}

/* -------------------- UI -------------------- */

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem(this.icon, this.label);
}

class _AnimatedBottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          width: width * 0.95, // مش بعرض الشاشة كلها
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(28), // حواف كيرفد
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Row(
              children: List.generate(items.length, (index) {
                final selected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: selected ? primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            items[index].icon,
                            color: selected ? primary : Colors.grey.shade500,
                            size: selected ? 28 : 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items[index].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? primary : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
