import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_event.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';
import 'screens/main_screen.dart';
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
        // ✅ Create BLoCs without loading data - data will load after authentication
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating ExpenseBloc (data will load after auth)');
            return ExpenseBloc(
              expenseApiService: serviceLocator.expenseApiService,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating SettingsBloc (data will load after auth)');
            return SettingsBloc(
              apiService: serviceLocator.settingsApiService,
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating AccountBloc (data will load after auth)');
            return AccountBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating BudgetBloc (data will load after auth)');
            return BudgetBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint(
              '🚀 Creating RecurringExpenseBloc (data will load after auth)',
            );
            return RecurringExpenseBloc();
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating UserBloc (data will load after auth)');
            return UserBloc();
          },
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
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

          // حفظ AppMode بناءً على accountType من API
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

          // Auto-login: Set current user in UserBloc and load initial data
          if (mounted) {
            await _setCurrentUserInBloc(user);
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

  /// Set the current user in UserBloc after successful auto-login
  Future<void> _setCurrentUserInBloc(UserModel apiUser) async {
    try {
      // Parse user role from API response
      final userRole = UserRole.values.firstWhere(
        (role) => role.name == apiUser.role?.toLowerCase(),
        orElse: () => UserRole.owner,
      );

      debugPrint('👤 Auto-login: User role from API: ${apiUser.role} -> ${userRole.name}');

      // Clear state BEFORE setting new user (to prevent data leakage)
      await userContextManager.onUserContextChanged(
        userId: apiUser.id,
        role: userRole,
        companyId: apiUser.companyId,
        context: context,
      );

      // Create User object for UserBloc
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

      // Update UserBloc with current user
      context.read<UserBloc>().add(SetCurrentUser(currentUser));

      // Note: Settings and other data will be loaded in _loadInitialData()
      debugPrint('✅ Auto-login: UserBloc updated with current user');
    } catch (e) {
      debugPrint('❌ Error setting user in BLoC: $e');
    }
  }

  /// Load initial data after authentication
  /// Only called once after successful auto-login to prevent duplicate API calls
  void _loadInitialData(BuildContext context) {
    try {
      debugPrint('📦 Loading initial data after authentication...');

      // Load settings first (needed for app mode) - Force reload to refresh appMode/companyId
      context.read<SettingsBloc>().add(const LoadSettings(forceReload: true));

      // Load accounts (needed for default account)
      context.read<AccountBloc>().add(const InitializeAccounts());

      // Load other data (expenses, budgets, recurring expenses, categories)
      // Force refresh expenses to ensure they reload after user context change
      context.read<ExpenseBloc>().add(const LoadExpenses(forceRefresh: true));

      final now = DateTime.now();
      context.read<BudgetBloc>().add(LoadBudgetsForMonth(now.year, now.month));

      context.read<RecurringExpenseBloc>().add(const LoadRecurringExpenses());

      context.read<UserBloc>().add(const LoadUsers());

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
