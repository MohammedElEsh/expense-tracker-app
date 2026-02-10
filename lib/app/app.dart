import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'package:expense_tracker/app/pages/main_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_service.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Create Cubits without loading data - data will load after authentication
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating ExpenseCubit (data will load after auth)');
            return ExpenseCubit(
              expenseApiService: serviceLocator.expenseApiService,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating SettingsCubit (data will load after auth)');
            return SettingsCubit(apiService: serviceLocator.settingsApiService);
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating AccountCubit (data will load after auth)');
            return AccountCubit();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating BudgetCubit (data will load after auth)');
            return BudgetCubit();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint(
              '🚀 Creating RecurringExpenseCubit (data will load after auth)',
            );
            return RecurringExpenseCubit();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating UserCubit (data will load after auth)');
            return UserCubit();
          },
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Spendly',
            theme: settings.themeData,
            home: _AuthStateHandler(settings: settings),
            debugShowCheckedModeBanner: false,
            locale: Locale(settings.language),
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}

/// Handles authentication state using REST API token
class _AuthStateHandler extends StatefulWidget {
  final SettingsState settings;

  const _AuthStateHandler({required this.settings});

  @override
  State<_AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<_AuthStateHandler> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if user has valid token
      final token = await serviceLocator.prefHelper.getAuthToken();

      if (token != null && token.isNotEmpty) {
        // Try to get current user to validate token
        try {
          final user =
              await serviceLocator.authRemoteDataSource.getCurrentUser();

          // Save AppMode based on accountType from API
          if (user.accountType == 'business') {
            await SettingsService.setAppMode(AppMode.business);
            if (user.companyId != null) {
              await SettingsService.setCompanyId(user.companyId);
            }
            debugPrint('✅ Business mode set from API');
          } else {
            await SettingsService.setAppMode(AppMode.personal);
            await SettingsService.setCompanyId(null);
            debugPrint('✅ Personal mode set from API');
          }

          setState(() {
            _isAuthenticated = true;
            _userId = user.id;
            _isLoading = false;
          });

          // Auto-login: Set current user in UserCubit and load initial data
          if (mounted) {
            await _setCurrentUserInCubit(user);
            // Load initial data after authentication
            _loadInitialData(context);
          }

          debugPrint('✅ User authenticated (auto-login): ${user.email}');
          return;
        } catch (e) {
          debugPrint('⚠️ Token invalid or expired: $e');
          // Token is invalid, clear it
          await serviceLocator.authRemoteDataSource.logout();
          await SettingsService.clearModeAndCompany();
        }
      }

      setState(() {
        _isAuthenticated = false;
        _userId = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking auth state: $e');
      setState(() {
        _isAuthenticated = false;
        _userId = null;
        _isLoading = false;
      });
    }
  }

  /// Set the current user in UserCubit after successful auto-login
  Future<void> _setCurrentUserInCubit(UserModel apiUser) async {
    try {
      // Parse user role from API response
      final userRole = UserRole.values.firstWhere(
        (role) => role.name == apiUser.role?.toLowerCase(),
        orElse: () => UserRole.owner,
      );

      debugPrint(
        '👤 Auto-login: User role from API: ${apiUser.role} -> ${userRole.name}',
      );

      // Clear state BEFORE setting new user (to prevent data leakage)
      await userContextManager.onUserContextChanged(
        userId: apiUser.id,
        role: userRole,
        companyId: apiUser.companyId,
        context: context,
      );

      // Create User object for UserCubit
      final currentUser = User(
        id: apiUser.id,
        name: apiUser.name,
        email: apiUser.email,
        phone: apiUser.phone,
        role: userRole,
        department: null,
        isActive: apiUser.isActive,
        createdAt: apiUser.createdAt ?? DateTime.now(),
        lastLoginAt: apiUser.lastLogin,
      );

      // Update UserCubit with current user
      context.read<UserCubit>().setCurrentUser(currentUser);

      // Note: Settings and other data will be loaded in _loadInitialData()
      debugPrint('✅ Auto-login: UserCubit updated with current user');
    } catch (e) {
      debugPrint('❌ Error setting user in Cubit: $e');
    }
  }

  /// Load initial data after authentication
  /// Only called once after successful auto-login to prevent duplicate API calls
  void _loadInitialData(BuildContext context) {
    try {
      debugPrint('📦 Loading initial data after authentication...');

      // Load settings first (needed for app mode) - Force reload to refresh appMode/companyId
      context.read<SettingsCubit>().loadSettings(forceReload: true);

      // Load accounts (needed for default account)
      context.read<AccountCubit>().initializeAccounts();

      // Load other data (expenses, budgets, recurring expenses, categories)
      // Force refresh expenses to ensure they reload after user context change
      context.read<ExpenseCubit>().loadExpenses(forceRefresh: true);

      final now = DateTime.now();
      context.read<BudgetCubit>().loadBudgetsForMonth(now.year, now.month);

      context.read<RecurringExpenseCubit>().loadRecurringExpenses();

      context.read<UserCubit>().loadUsers();

      debugPrint('✅ Initial data load initiated');
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Not authenticated
    if (!_isAuthenticated) {
      if (!OnboardingService.isOnboardingCompleted) {
        return const OnboardingScreen();
      }
      return const SimpleLoginScreen();
    }

    // Authenticated - navigate to main screen
    debugPrint('✅ المستخدم مسجل دخول: $_userId');
    return MainScreen(key: ValueKey(_userId ?? 'main'));
  }
}
