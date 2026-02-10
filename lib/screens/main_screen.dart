import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import '../services/permission_service.dart';
import '../utils/responsive_utils.dart';
import 'package:expense_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:expense_tracker/features/statistics/presentation/pages/statistics_screen.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_management_screen.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_screen_refactored.dart';
import '../features/auth/presentation/pages/signup_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
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

  /// Load data for current user
  /// Ensures data is reloaded when user changes (but not on initial app load)
  /// Initial load is handled in _AuthStateHandler._loadInitialData() which sets hasLoaded flags
  void _loadDataForCurrentUser() {
    final currentUser = context.read<UserBloc>().state.currentUser;

    // Only reload if user actually changed (not on initial load)
    // Initial load is handled centrally in _AuthStateHandler._loadInitialData()
    if (currentUser != null && _lastLoadedUserId != currentUser.id) {
      debugPrint(
        '🔄 User changed - Loading data for user: ${currentUser.id} (role: ${currentUser.role.name})',
      );

      // Force refresh all data when user changes to ensure fresh data for new user context
      context.read<AccountBloc>().add(const InitializeAccounts());
      context.read<ExpenseBloc>().add(const LoadExpenses(forceRefresh: true));
      context.read<BudgetBloc>().add(const LoadBudgets());
      context.read<RecurringExpenseBloc>().add(const LoadRecurringExpenses());

      // Update last loaded user ID
      _lastLoadedUserId = currentUser.id;
    } else if (currentUser == null && _lastLoadedUserId != null) {
      // User logged out - clear loaded user ID
      _lastLoadedUserId = null;
    }

    // ⏳ إزالة حالة التهيئة بعد 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, currentState) {
        // Only reload expenses when app mode changes (not on every settings change)
        // This prevents unnecessary API calls on settings updates
        // Note: ReloadExpensesForCurrentMode already handles mode-specific filtering
        // If needed, compare previous mode with current mode to avoid duplicate calls
      },
      child: BlocListener<UserBloc, UserState>(
        listener: (context, userState) {
          // Reload data when user changes (login/logout/role switch)
          _loadDataForCurrentUser();
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                // التحقق من تسجيل الدخول
                if (userState.currentUser == null) {
                  // ⏳ إذا كنا في مرحلة التهيئة، عرض شاشة تحميل
                  if (_isInitializing) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  // ❌ إذا لم يكن هناك مستخدم بعد التهيئة، الرجوع للشاشة الترحيبية
                  return const WelcomeScreen();
                }

                final isRTL = settings.language == 'ar';
                final currentUser = userState.currentUser;

                // Define screens based on app mode and user permissions
                final screens = <Widget>[
                  const HomeScreen(),
                  const StatisticsScreen(),
                  // Budget Management available in both modes
                  // - Personal: Everyone can manage budgets
                  // - Business: Only users with permission
                  if (settings.appMode == AppMode.personal ||
                      (settings.appMode == AppMode.business &&
                          currentUser != null &&
                          PermissionService.canManageBudgets(currentUser)))
                    const BudgetManagementScreen(),
                  const SettingsScreenRefactored(),
                ];

                // Define bottom navigation items based on app mode and permissions
                final bottomNavItems = <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: isRTL ? 'الرئيسية' : 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.analytics),
                    label: isRTL ? 'الإحصائيات' : 'Statistics',
                  ),
                  // Budget available in both modes
                  if (settings.appMode == AppMode.personal ||
                      (settings.appMode == AppMode.business &&
                          currentUser != null &&
                          PermissionService.canManageBudgets(currentUser)))
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.account_balance_wallet),
                      label: isRTL ? 'الميزانية' : 'Budget',
                    ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: isRTL ? 'الإعدادات' : 'Settings',
                  ),
                ];

                // Adjust current index if budget screen is not available
                final adjustedIndex = _adjustIndexForPermissions(
                  _currentIndex,
                  currentUser,
                  settings.appMode,
                );

                // 🖥️ استخدام تخطيط مختلف بناءً على نوع الجهاز
                final isDesktop = ResponsiveUtils.isDesktop(context);

                return PopScope(
                  canPop: adjustedIndex == 0,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop && adjustedIndex != 0) {
                      setState(() {
                        _currentIndex = 0;
                      });
                    }
                  },
                  child:
                      isDesktop
                          ? _buildDesktopLayout(
                            screens,
                            adjustedIndex,
                            isRTL,
                            currentUser,
                            settings.appMode,
                          )
                          : _buildMobileLayout(
                            screens,
                            bottomNavItems,
                            adjustedIndex,
                            currentUser,
                            settings.appMode,
                          ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  int _adjustIndexForPermissions(
    int originalIndex,
    User? currentUser,
    AppMode appMode,
  ) {
    // If budget management is not available, adjust indices
    final budgetAvailable =
        appMode == AppMode.personal ||
        (appMode == AppMode.business &&
            currentUser != null &&
            PermissionService.canManageBudgets(currentUser));

    if (!budgetAvailable) {
      if (originalIndex >= 2) {
        return originalIndex - 1;
      }
    }
    return originalIndex;
  }

  int _getOriginalIndex(int adjustedIndex, User? currentUser, AppMode appMode) {
    // Convert adjusted index back to original index
    final budgetAvailable =
        appMode == AppMode.personal ||
        (appMode == AppMode.business &&
            currentUser != null &&
            PermissionService.canManageBudgets(currentUser));

    if (!budgetAvailable) {
      if (adjustedIndex >= 2) {
        return adjustedIndex + 1;
      }
    }
    return adjustedIndex;
  }

  /// 🖥️ Desktop Layout with NavigationRail
  Widget _buildDesktopLayout(
    List<Widget> screens,
    int adjustedIndex,
    bool isRTL,
    User? currentUser,
    AppMode appMode,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // NavigationRail للديسكتوب
          NavigationRail(
            selectedIndex: adjustedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = _getOriginalIndex(index, currentUser, appMode);
              });
            },
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
              if (appMode == AppMode.personal ||
                  (appMode == AppMode.business &&
                      currentUser != null &&
                      PermissionService.canManageBudgets(currentUser)))
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
          // المحتوى الرئيسي
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                child: IndexedStack(index: adjustedIndex, children: screens),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Mobile/Tablet Layout with BottomNavigationBar
  Widget _buildMobileLayout(
    List<Widget> screens,
    List<BottomNavigationBarItem> bottomNavItems,
    int adjustedIndex,
    User? currentUser,
    AppMode appMode,
  ) {
    return Scaffold(
      body: IndexedStack(index: adjustedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: adjustedIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = _getOriginalIndex(index, currentUser, appMode);
          });
        },
        type: BottomNavigationBarType.fixed,
        items: bottomNavItems,
      ),
    );
  }
}
