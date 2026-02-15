import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/set_app_mode_usecase.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/add_to_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/initialize_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/set_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/subtract_from_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/transfer_money_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/clear_budget_cache_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_cubit.dart';
import 'package:expense_tracker/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_companies_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/create_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/delete_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/disable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/enable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/get_recurring_expenses_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/update_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/get_statistics_usecase.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/create_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/delete_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_statistics_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/update_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_report_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_statistics_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:expense_tracker/features/home/domain/usecases/calculate_total_amount_usecase.dart';
import 'package:expense_tracker/features/home/domain/usecases/filter_expenses_by_view_mode_usecase.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_cubit.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/users/domain/usecases/create_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/delete_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/get_users_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/update_user_usecase.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/get_plans_usecase.dart';
import 'package:expense_tracker/features/subscriptions/presentation/cubit/subscriptions_cubit.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ Create Cubits without loading data - data will load after authentication
        // FIX: HomeCubit at app level so it persists across tab switches (no recreation).
        BlocProvider(
          create: (context) => HomeCubit(
            logoutUseCase: getIt<LogoutUseCase>(),
            filterExpensesByViewModeUseCase:
                getIt<FilterExpensesByViewModeUseCase>(),
            calculateTotalAmountUseCase: getIt<CalculateTotalAmountUseCase>(),
          ),
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating ExpenseCubit (data will load after auth)');
            return ExpenseCubit(
              getExpensesUseCase: getIt<GetExpensesUseCase>(),
              addExpenseUseCase: getIt<AddExpenseUseCase>(),
              updateExpenseUseCase: getIt<UpdateExpenseUseCase>(),
              deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating SettingsCubit (data will load after auth)');
            return SettingsCubit(
              getSettingsUseCase: getIt<GetSettingsUseCase>(),
              updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
              resetSettingsUseCase: getIt<ResetSettingsUseCase>(),
              setAppModeUseCase: getIt<SetAppModeUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating AccountCubit (data will load after auth)');
            return AccountCubit(
              getAccountsUseCase: getIt<GetAccountsUseCase>(),
              createAccountUseCase: getIt<CreateAccountUseCase>(),
              updateAccountUseCase: getIt<UpdateAccountUseCase>(),
              deleteAccountUseCase: getIt<DeleteAccountUseCase>(),
              getDefaultAccountUseCase: getIt<GetDefaultAccountUseCase>(),
              setDefaultAccountUseCase: getIt<SetDefaultAccountUseCase>(),
              initializeAccountsUseCase: getIt<InitializeAccountsUseCase>(),
              updateAccountBalanceUseCase: getIt<UpdateAccountBalanceUseCase>(),
              addToAccountBalanceUseCase: getIt<AddToAccountBalanceUseCase>(),
              subtractFromAccountBalanceUseCase:
                  getIt<SubtractFromAccountBalanceUseCase>(),
              transferMoneyUseCase: getIt<TransferMoneyUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating BudgetCubit (data will load after auth)');
            return BudgetCubit(
              getBudgetsUseCase: getIt<GetBudgetsUseCase>(),
              createBudgetUseCase: getIt<CreateBudgetUseCase>(),
              updateBudgetUseCase: getIt<UpdateBudgetUseCase>(),
              deleteBudgetUseCase: getIt<DeleteBudgetUseCase>(),
              clearBudgetCacheUseCase: getIt<ClearBudgetCacheUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint(
              '🚀 Creating StatisticsCubit (data will load when screen opens)',
            );
            return StatisticsCubit(
              getStatisticsUseCase: getIt<GetStatisticsUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating CompanyCubit (data will load when needed)');
            return CompanyCubit(
              getCompaniesUseCase: getIt<GetCompaniesUseCase>(),
              getCompanyByIdUseCase: getIt<GetCompanyByIdUseCase>(),
              createCompanyUseCase: getIt<CreateCompanyUseCase>(),
              updateCompanyUseCase: getIt<UpdateCompanyUseCase>(),
              deleteCompanyUseCase: getIt<DeleteCompanyUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint(
              '🚀 Creating RecurringExpenseCubit (data will load after auth)',
            );
            return RecurringExpenseCubit(
              getRecurringExpensesUseCase: getIt<GetRecurringExpensesUseCase>(),
              createRecurringExpenseUseCase:
                  getIt<CreateRecurringExpenseUseCase>(),
              updateRecurringExpenseUseCase:
                  getIt<UpdateRecurringExpenseUseCase>(),
              deleteRecurringExpenseUseCase:
                  getIt<DeleteRecurringExpenseUseCase>(),
              enableReminderUseCase: getIt<EnableRecurringReminderUseCase>(),
              disableReminderUseCase: getIt<DisableRecurringReminderUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating UserCubit (data will load after auth)');
            return UserCubit(
              getUsersUseCase: getIt<GetUsersUseCase>(),
              createUserUseCase: getIt<CreateUserUseCase>(),
              updateUserUseCase: getIt<UpdateUserUseCase>(),
              deleteUserUseCase: getIt<DeleteUserUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating ProjectCubit (data will load when needed)');
            return ProjectCubit(
              getProjectsUseCase: getIt<GetProjectsUseCase>(),
              getProjectByIdUseCase: getIt<GetProjectByIdUseCase>(),
              createProjectUseCase: getIt<CreateProjectUseCase>(),
              updateProjectUseCase: getIt<UpdateProjectUseCase>(),
              deleteProjectUseCase: getIt<DeleteProjectUseCase>(),
              getProjectReportUseCase: getIt<GetProjectReportUseCase>(),
              getProjectsStatisticsUseCase:
                  getIt<GetProjectsStatisticsUseCase>(),
            );
          },
        ),
        BlocProvider(create: (context) => getIt<OnboardingCubit>()),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating SubscriptionsCubit');
            return SubscriptionsCubit(
              getPlansUseCase: getIt<GetPlansUseCase>(),
            );
          },
        ),
        BlocProvider(
          create: (context) {
            debugPrint('🚀 Creating VendorCubit (data will load when needed)');
            return VendorCubit(
              getVendorsUseCase: getIt<GetVendorsUseCase>(),
              createVendorUseCase: getIt<CreateVendorUseCase>(),
              updateVendorUseCase: getIt<UpdateVendorUseCase>(),
              deleteVendorUseCase: getIt<DeleteVendorUseCase>(),
              getVendorsStatisticsUseCase: getIt<GetVendorsStatisticsUseCase>(),
            );
          },
        ),
      ],
      child: _AppRouterContent(),
    );
  }
}

/// Builds MaterialApp.router on first frame with default theme so the router
/// is never blocked. Listens to SettingsCubit for theme/locale updates.
class _AppRouterContent extends StatefulWidget {
  @override
  State<_AppRouterContent> createState() => _AppRouterContentState();
}

class _AppRouterContentState extends State<_AppRouterContent> {
  late ThemeData _theme;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    final defaults = const SettingsState();
    _theme = defaults.themeData;
    _locale = Locale(defaults.language);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.themeData != _theme || state.language != _locale.languageCode) {
          setState(() {
            _theme = state.themeData;
            _locale = Locale(state.language);
          });
        }
      },
      child: MaterialApp.router(
        title: 'Spendly',
        theme: _theme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: const [Locale('en', ''), Locale('ar', '')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
