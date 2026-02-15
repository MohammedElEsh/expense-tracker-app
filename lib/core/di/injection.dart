import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/data/app_context_impl.dart';
import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_api_service.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/reset_settings_usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/set_app_mode_usecase.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_service.dart';
import 'package:expense_tracker/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/get_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/set_default_account_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/initialize_accounts_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/update_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/add_to_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/subtract_from_account_balance_usecase.dart';
import 'package:expense_tracker/features/accounts/domain/usecases/transfer_money_usecase.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_service.dart';
import 'package:expense_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/clear_budget_cache_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/create_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/update_budget_usecase.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_api_service.dart';
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expense_by_id_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:expense_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:expense_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/aggregate_data_usecase.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/calculate_trends_usecase.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/filter_by_period_usecase.dart';
import 'package:expense_tracker/features/statistics/domain/usecases/get_statistics_usecase.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/companies/data/repositories/company_repository_impl.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_companies_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:expense_tracker/features/vendors/data/datasources/vendor_service.dart';
import 'package:expense_tracker/features/vendors/data/repositories/vendor_repository_impl.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/create_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/delete_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendor_by_id_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_statistics_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/update_vendor_usecase.dart';
import 'package:expense_tracker/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:expense_tracker/features/projects/data/repositories/project_repository_impl.dart';
import 'package:expense_tracker/features/projects/domain/repositories/project_repository.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_project_report_usecase.dart';
import 'package:expense_tracker/features/projects/domain/usecases/get_projects_statistics_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_notification_service.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/usecases/apply_user_context_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/clear_app_context_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_business_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_personal_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/login_cubit.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/signup_cubit.dart';
import 'package:expense_tracker/features/home/domain/usecases/calculate_total_amount_usecase.dart';
import 'package:expense_tracker/features/home/domain/usecases/filter_expenses_by_view_mode_usecase.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_remote_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_notification_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_reminder_preferences_datasource.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_reminder_preferences_datasource_impl.dart';
import 'package:expense_tracker/features/recurring_expenses/data/repositories/recurring_expense_repository_impl.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/get_recurring_expenses_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/create_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/update_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/delete_recurring_expense_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/enable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/disable_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/get_recurring_reminders_enabled_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/set_recurring_reminders_enabled_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/show_test_recurring_reminder_usecase.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/usecases/reschedule_all_recurring_reminders_usecase.dart';
import 'package:expense_tracker/features/users/data/datasources/user_remote_datasource.dart';
import 'package:expense_tracker/features/users/data/repositories/user_repository_impl.dart';
import 'package:expense_tracker/features/users/domain/repositories/user_repository.dart';
import 'package:expense_tracker/features/users/domain/usecases/get_users_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/get_user_by_id_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/create_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/update_user_usecase.dart';
import 'package:expense_tracker/features/users/domain/usecases/delete_user_usecase.dart';
import 'package:expense_tracker/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:expense_tracker/features/ocr/data/datasources/ocr_remote_datasource.dart';
import 'package:expense_tracker/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/scan_receipt_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/parse_receipt_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/pick_image_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/create_expense_from_ocr_usecase.dart';
import 'package:expense_tracker/features/ocr/presentation/cubit/ocr_cubit.dart';
import 'package:expense_tracker/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:expense_tracker/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:expense_tracker/features/notifications/domain/repositories/notification_repository.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/disable_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/enable_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/get_notifications_enabled_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import 'package:expense_tracker/features/notifications/domain/usecases/reschedule_notifications_usecase.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:expense_tracker/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:expense_tracker/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/get_current_step_usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_step_usecase.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/skip_onboarding_usecase.dart';
import 'package:expense_tracker/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:expense_tracker/features/subscriptions/data/repositories/subscription_repository_impl.dart';
import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/cancel_subscription_usecase.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/check_status_usecase.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/get_plans_usecase.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/subscribe_user_usecase.dart';
import 'package:expense_tracker/features/subscriptions/presentation/cubit/subscriptions_cubit.dart';

final getIt = GetIt.instance;

Future<void> initInjector() async {
  await getIt.reset();

  getIt.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  getIt.registerSingletonAsync<AppContext>(
    () async => AppContextImpl(await getIt.getAsync<SharedPreferences>()),
  );

  getIt.registerSingletonAsync<PrefHelper>(() async => PrefHelper());

  getIt.registerSingletonAsync<RecurringReminderPreferencesDataSource>(
    () async => RecurringReminderPreferencesDataSourceImpl(
      await getIt.getAsync<PrefHelper>(),
    ),
  );

  getIt.registerSingletonAsync<DioClient>(
    () async => DioClient(await getIt.getAsync<PrefHelper>()),
  );

  getIt.registerSingletonAsync<ApiService>(
    () async => ApiService((await getIt.getAsync<DioClient>()).dio),
  );

  getIt.registerSingletonAsync<SettingsApiService>(
    () async =>
        SettingsApiService(apiService: await getIt.getAsync<ApiService>()),
  );

  getIt.registerSingletonAsync<AuthRemoteDataSource>(
    () async => AuthRemoteDataSource(
      apiService: await getIt.getAsync<ApiService>(),
      prefHelper: await getIt.getAsync<PrefHelper>(),
    ),
  );

  getIt.registerSingletonAsync<AuthRepository>(
    () async => AuthRepositoryImpl(
      remoteDataSource: await getIt.getAsync<AuthRemoteDataSource>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<LoginUseCase>(
    () async => LoginUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<LogoutUseCase>(
    () async => LogoutUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<ApplyUserContextUseCase>(
    () async => ApplyUserContextUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<ClearAppContextUseCase>(
    () async => ClearAppContextUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<RegisterPersonalUseCase>(
    () async => RegisterPersonalUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<RegisterBusinessUseCase>(
    () async => RegisterBusinessUseCase(await getIt.getAsync<AuthRepository>()),
  );
  getIt.registerSingletonAsync<ResendVerificationUseCase>(
    () async =>
        ResendVerificationUseCase(await getIt.getAsync<AuthRepository>()),
  );

  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginUseCase: getIt<LoginUseCase>(),
      resendVerificationUseCase: getIt<ResendVerificationUseCase>(),
      applyUserContextUseCase: getIt<ApplyUserContextUseCase>(),
    ),
  );
  getIt.registerFactory<SignupCubit>(
    () => SignupCubit(
      registerPersonalUseCase: getIt<RegisterPersonalUseCase>(),
      registerBusinessUseCase: getIt<RegisterBusinessUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      applyUserContextUseCase: getIt<ApplyUserContextUseCase>(),
      clearAppContextUseCase: getIt<ClearAppContextUseCase>(),
    ),
  );

  getIt.registerFactory<FilterExpensesByViewModeUseCase>(
    () => FilterExpensesByViewModeUseCase(),
  );
  getIt.registerFactory<CalculateTotalAmountUseCase>(
    () => CalculateTotalAmountUseCase(),
  );
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      logoutUseCase: getIt<LogoutUseCase>(),
      filterExpensesByViewModeUseCase: getIt<FilterExpensesByViewModeUseCase>(),
      calculateTotalAmountUseCase: getIt<CalculateTotalAmountUseCase>(),
    ),
  );

  getIt.registerSingletonAsync<SettingsRepository>(
    () async => SettingsRepositoryImpl(
      appContext: await getIt.getAsync<AppContext>(),
      apiService: null,
    ),
  );

  getIt.registerSingletonAsync<GetSettingsUseCase>(
    () async => GetSettingsUseCase(await getIt.getAsync<SettingsRepository>()),
  );

  getIt.registerSingletonAsync<UpdateSettingsUseCase>(
    () async =>
        UpdateSettingsUseCase(await getIt.getAsync<SettingsRepository>()),
  );

  getIt.registerSingletonAsync<ResetSettingsUseCase>(
    () async =>
        ResetSettingsUseCase(await getIt.getAsync<SettingsRepository>()),
  );

  getIt.registerSingletonAsync<SetAppModeUseCase>(
    () async => SetAppModeUseCase(await getIt.getAsync<SettingsRepository>()),
  );

  getIt.registerSingletonAsync<AccountService>(
    () async => AccountService(
      apiService: await getIt.getAsync<ApiService>(),
      prefHelper: await getIt.getAsync<PrefHelper>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<AccountRepository>(
    () async => AccountRepositoryImpl(
      accountService: await getIt.getAsync<AccountService>(),
    ),
  );

  getIt.registerSingletonAsync<GetAccountsUseCase>(
    () async => GetAccountsUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<CreateAccountUseCase>(
    () async => CreateAccountUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<UpdateAccountUseCase>(
    () async => UpdateAccountUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<DeleteAccountUseCase>(
    () async => DeleteAccountUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<GetDefaultAccountUseCase>(
    () async =>
        GetDefaultAccountUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<SetDefaultAccountUseCase>(
    () async =>
        SetDefaultAccountUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<InitializeAccountsUseCase>(
    () async =>
        InitializeAccountsUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<UpdateAccountBalanceUseCase>(
    () async =>
        UpdateAccountBalanceUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<AddToAccountBalanceUseCase>(
    () async =>
        AddToAccountBalanceUseCase(await getIt.getAsync<AccountRepository>()),
  );
  getIt.registerSingletonAsync<SubtractFromAccountBalanceUseCase>(
    () async => SubtractFromAccountBalanceUseCase(
      await getIt.getAsync<AccountRepository>(),
    ),
  );
  getIt.registerSingletonAsync<TransferMoneyUseCase>(
    () async => TransferMoneyUseCase(await getIt.getAsync<AccountRepository>()),
  );

  getIt.registerSingletonAsync<BudgetService>(
    () async => BudgetService(
      apiService: await getIt.getAsync<ApiService>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<BudgetRepository>(
    () async => BudgetRepositoryImpl(
      budgetService: await getIt.getAsync<BudgetService>(),
    ),
  );

  getIt.registerSingletonAsync<GetBudgetsUseCase>(
    () async => GetBudgetsUseCase(await getIt.getAsync<BudgetRepository>()),
  );
  getIt.registerSingletonAsync<CreateBudgetUseCase>(
    () async => CreateBudgetUseCase(await getIt.getAsync<BudgetRepository>()),
  );
  getIt.registerSingletonAsync<UpdateBudgetUseCase>(
    () async => UpdateBudgetUseCase(await getIt.getAsync<BudgetRepository>()),
  );
  getIt.registerSingletonAsync<DeleteBudgetUseCase>(
    () async => DeleteBudgetUseCase(await getIt.getAsync<BudgetRepository>()),
  );
  getIt.registerSingletonAsync<ClearBudgetCacheUseCase>(
    () async =>
        ClearBudgetCacheUseCase(await getIt.getAsync<BudgetRepository>()),
  );

  getIt.registerSingletonAsync<ExpenseApiService>(
    () async => ExpenseApiService(
      apiService: await getIt.getAsync<ApiService>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<ExpenseRepository>(
    () async => ExpenseRepositoryImpl(
      expenseApiService: await getIt.getAsync<ExpenseApiService>(),
    ),
  );

  getIt.registerSingletonAsync<GetExpensesUseCase>(
    () async => GetExpensesUseCase(await getIt.getAsync<ExpenseRepository>()),
  );
  getIt.registerSingletonAsync<AddExpenseUseCase>(
    () async => AddExpenseUseCase(await getIt.getAsync<ExpenseRepository>()),
  );
  getIt.registerSingletonAsync<UpdateExpenseUseCase>(
    () async => UpdateExpenseUseCase(await getIt.getAsync<ExpenseRepository>()),
  );
  getIt.registerSingletonAsync<DeleteExpenseUseCase>(
    () async => DeleteExpenseUseCase(await getIt.getAsync<ExpenseRepository>()),
  );
  getIt.registerSingletonAsync<GetExpenseByIdUseCase>(
    () async =>
        GetExpenseByIdUseCase(await getIt.getAsync<ExpenseRepository>()),
  );

  // Statistics (depends on GetExpensesUseCase, GetBudgetsUseCase).
  // Lazy so factory runs on first request, not during register (avoids GetIt parallel-init race).
  getIt.registerLazySingletonAsync<StatisticsRepository>(
    () async => StatisticsRepositoryImpl(
      getExpensesUseCase: await getIt.getAsync<GetExpensesUseCase>(),
      getBudgetsUseCase: await getIt.getAsync<GetBudgetsUseCase>(),
    ),
  );
  getIt.registerLazySingletonAsync<GetStatisticsUseCase>(
    () async =>
        GetStatisticsUseCase(await getIt.getAsync<StatisticsRepository>()),
  );
  getIt.registerLazySingletonAsync<CalculateTrendsUseCase>(
    () async =>
        CalculateTrendsUseCase(await getIt.getAsync<StatisticsRepository>()),
  );
  getIt.registerLazySingletonAsync<FilterByPeriodUseCase>(
    () async =>
        FilterByPeriodUseCase(await getIt.getAsync<StatisticsRepository>()),
  );
  getIt.registerLazySingletonAsync<AggregateDataUseCase>(
    () async =>
        AggregateDataUseCase(await getIt.getAsync<StatisticsRepository>()),
  );

  getIt.registerSingletonAsync<CompanyApiService>(
    () async => CompanyApiService(
      apiService: await getIt.getAsync<ApiService>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<CompanyRepository>(
    () async => CompanyRepositoryImpl(
      companyApiService: await getIt.getAsync<CompanyApiService>(),
    ),
  );

  getIt.registerSingletonAsync<GetCompaniesUseCase>(
    () async => GetCompaniesUseCase(await getIt.getAsync<CompanyRepository>()),
  );
  getIt.registerSingletonAsync<GetCompanyByIdUseCase>(
    () async =>
        GetCompanyByIdUseCase(await getIt.getAsync<CompanyRepository>()),
  );
  getIt.registerSingletonAsync<CreateCompanyUseCase>(
    () async => CreateCompanyUseCase(await getIt.getAsync<CompanyRepository>()),
  );
  getIt.registerSingletonAsync<UpdateCompanyUseCase>(
    () async => UpdateCompanyUseCase(await getIt.getAsync<CompanyRepository>()),
  );
  getIt.registerSingletonAsync<DeleteCompanyUseCase>(
    () async => DeleteCompanyUseCase(await getIt.getAsync<CompanyRepository>()),
  );

  getIt.registerSingletonAsync<VendorService>(
    () async => VendorService(
      apiService: await getIt.getAsync<ApiService>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<VendorRepository>(
    () async => VendorRepositoryImpl(
      vendorService: await getIt.getAsync<VendorService>(),
    ),
  );

  getIt.registerSingletonAsync<GetVendorsUseCase>(
    () async => GetVendorsUseCase(await getIt.getAsync<VendorRepository>()),
  );
  getIt.registerSingletonAsync<GetVendorByIdUseCase>(
    () async => GetVendorByIdUseCase(await getIt.getAsync<VendorRepository>()),
  );
  getIt.registerSingletonAsync<CreateVendorUseCase>(
    () async => CreateVendorUseCase(await getIt.getAsync<VendorRepository>()),
  );
  getIt.registerSingletonAsync<UpdateVendorUseCase>(
    () async => UpdateVendorUseCase(await getIt.getAsync<VendorRepository>()),
  );
  getIt.registerSingletonAsync<DeleteVendorUseCase>(
    () async => DeleteVendorUseCase(await getIt.getAsync<VendorRepository>()),
  );
  getIt.registerSingletonAsync<GetVendorsStatisticsUseCase>(
    () async =>
        GetVendorsStatisticsUseCase(await getIt.getAsync<VendorRepository>()),
  );

  getIt.registerSingletonAsync<ProjectRemoteDataSource>(
    () async => ProjectRemoteDataSource(
      apiService: await getIt.getAsync<ApiService>(),
      appContext: await getIt.getAsync<AppContext>(),
    ),
  );

  getIt.registerSingletonAsync<ProjectRepository>(
    () async => ProjectRepositoryImpl(
      dataSource: await getIt.getAsync<ProjectRemoteDataSource>(),
    ),
  );

  getIt.registerSingletonAsync<GetProjectsUseCase>(
    () async => GetProjectsUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<GetProjectByIdUseCase>(
    () async =>
        GetProjectByIdUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<CreateProjectUseCase>(
    () async => CreateProjectUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<UpdateProjectUseCase>(
    () async => UpdateProjectUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<DeleteProjectUseCase>(
    () async => DeleteProjectUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<GetProjectReportUseCase>(
    () async =>
        GetProjectReportUseCase(await getIt.getAsync<ProjectRepository>()),
  );
  getIt.registerSingletonAsync<GetProjectsStatisticsUseCase>(
    () async =>
        GetProjectsStatisticsUseCase(await getIt.getAsync<ProjectRepository>()),
  );

  getIt.registerSingletonAsync<RecurringExpenseNotificationService>(() async {
    final s = RecurringExpenseNotificationService();
    await s.initialize();
    return s;
  });

  getIt.registerSingletonAsync<RecurringExpenseRemoteDataSource>(
    () async => RecurringExpenseRemoteDataSource(
      apiService: await getIt.getAsync<ApiService>(),
    ),
  );

  getIt.registerLazySingletonAsync<RecurringExpenseNotificationDataSource>(
    () async => RecurringExpenseNotificationDataSource(
      notificationService:
          await getIt.getAsync<RecurringExpenseNotificationService>(),
      reminderPrefs:
          await getIt.getAsync<RecurringReminderPreferencesDataSource>(),
    ),
  );

  getIt.registerLazySingletonAsync<RecurringExpenseRepository>(
    () async => RecurringExpenseRepositoryImpl(
      remote: await getIt.getAsync<RecurringExpenseRemoteDataSource>(),
      notification:
          await getIt.getAsync<RecurringExpenseNotificationDataSource>(),
      reminderPrefs:
          await getIt.getAsync<RecurringReminderPreferencesDataSource>(),
    ),
  );

  getIt.registerLazySingletonAsync<GetRecurringExpensesUseCase>(
    () async => GetRecurringExpensesUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<CreateRecurringExpenseUseCase>(
    () async => CreateRecurringExpenseUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<UpdateRecurringExpenseUseCase>(
    () async => UpdateRecurringExpenseUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<DeleteRecurringExpenseUseCase>(
    () async => DeleteRecurringExpenseUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<EnableRecurringReminderUseCase>(
    () async => EnableRecurringReminderUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<DisableRecurringReminderUseCase>(
    () async => DisableRecurringReminderUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<GetRecurringRemindersEnabledUseCase>(
    () async => GetRecurringRemindersEnabledUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<SetRecurringRemindersEnabledUseCase>(
    () async => SetRecurringRemindersEnabledUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<ShowTestRecurringReminderUseCase>(
    () async => ShowTestRecurringReminderUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );
  getIt.registerLazySingletonAsync<RescheduleAllRecurringRemindersUseCase>(
    () async => RescheduleAllRecurringRemindersUseCase(
      await getIt.getAsync<RecurringExpenseRepository>(),
    ),
  );

  getIt.registerSingletonAsync<UserRemoteDataSource>(
    () async =>
        UserRemoteDataSource(apiService: await getIt.getAsync<ApiService>()),
  );
  getIt.registerSingletonAsync<UserRepository>(
    () async => UserRepositoryImpl(
      remote: await getIt.getAsync<UserRemoteDataSource>(),
    ),
  );
  getIt.registerSingletonAsync<GetUsersUseCase>(
    () async => GetUsersUseCase(await getIt.getAsync<UserRepository>()),
  );
  getIt.registerSingletonAsync<GetUserByIdUseCase>(
    () async => GetUserByIdUseCase(await getIt.getAsync<UserRepository>()),
  );
  getIt.registerSingletonAsync<CreateUserUseCase>(
    () async => CreateUserUseCase(await getIt.getAsync<UserRepository>()),
  );
  getIt.registerSingletonAsync<UpdateUserUseCase>(
    () async => UpdateUserUseCase(await getIt.getAsync<UserRepository>()),
  );
  getIt.registerSingletonAsync<DeleteUserUseCase>(
    () async => DeleteUserUseCase(await getIt.getAsync<UserRepository>()),
  );

  // OCR feature
  getIt.registerLazySingleton<OcrRemoteDataSource>(
    () => const OcrRemoteDataSource(),
  );
  getIt.registerLazySingleton<OcrLocalDataSource>(() => OcrLocalDataSource());
  getIt.registerLazySingleton<OcrRepository>(
    () => OcrRepositoryImpl(
      remote: getIt<OcrRemoteDataSource>(),
      local: getIt<OcrLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<PickImageUseCase>(
    () => PickImageUseCase(getIt<OcrRepository>()),
  );
  getIt.registerLazySingleton<ScanReceiptUseCase>(
    () => ScanReceiptUseCase(getIt<OcrRepository>()),
  );
  getIt.registerLazySingleton<ParseReceiptUseCase>(
    () => ParseReceiptUseCase(getIt<OcrRepository>()),
  );
  getIt.registerLazySingleton<CreateExpenseFromOcrUseCase>(
    () => CreateExpenseFromOcrUseCase(getIt<OcrRepository>()),
  );
  getIt.registerFactory<OcrCubit>(
    () => OcrCubit(
      pickImageUseCase: getIt<PickImageUseCase>(),
      scanReceiptUseCase: getIt<ScanReceiptUseCase>(),
      parseReceiptUseCase: getIt<ParseReceiptUseCase>(),
      createExpenseFromOcrUseCase: getIt<CreateExpenseFromOcrUseCase>(),
    ),
  );

  // Notifications feature (light Clean Architecture)
  getIt.registerLazySingleton<LocalNotificationDataSource>(
    () => const LocalNotificationDataSource(),
  );
  getIt.registerSingletonAsync<NotificationRepository>(
    () async => NotificationRepositoryImpl(
      dataSource: getIt<LocalNotificationDataSource>(),
      notificationService:
          await getIt.getAsync<RecurringExpenseNotificationService>(),
    ),
  );
  getIt.registerSingletonAsync<GetNotificationsEnabledUseCase>(
    () async => GetNotificationsEnabledUseCase(
      await getIt.getAsync<NotificationRepository>(),
    ),
  );
  getIt.registerSingletonAsync<EnableNotificationsUseCase>(
    () async => EnableNotificationsUseCase(
      await getIt.getAsync<NotificationRepository>(),
    ),
  );
  getIt.registerSingletonAsync<DisableNotificationsUseCase>(
    () async => DisableNotificationsUseCase(
      await getIt.getAsync<NotificationRepository>(),
    ),
  );
  getIt.registerSingletonAsync<RescheduleNotificationsUseCase>(
    () async => RescheduleNotificationsUseCase(
      await getIt.getAsync<NotificationRepository>(),
    ),
  );
  getIt.registerSingletonAsync<RequestNotificationPermissionUseCase>(
    () async => RequestNotificationPermissionUseCase(
      await getIt.getAsync<NotificationRepository>(),
    ),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsEnabledUseCase: getIt<GetNotificationsEnabledUseCase>(),
      enableNotificationsUseCase: getIt<EnableNotificationsUseCase>(),
      disableNotificationsUseCase: getIt<DisableNotificationsUseCase>(),
      rescheduleNotificationsUseCase: getIt<RescheduleNotificationsUseCase>(),
      getRecurringRemindersEnabledUseCase:
          getIt<GetRecurringRemindersEnabledUseCase>(),
      setRecurringRemindersEnabledUseCase:
          getIt<SetRecurringRemindersEnabledUseCase>(),
      rescheduleAllRecurringRemindersUseCase:
          getIt<RescheduleAllRecurringRemindersUseCase>(),
      showTestRecurringReminderUseCase:
          getIt<ShowTestRecurringReminderUseCase>(),
      requestNotificationPermissionUseCase:
          getIt<RequestNotificationPermissionUseCase>(),
    ),
  );

  // Onboarding feature
  getIt.registerSingletonAsync<OnboardingLocalDataSource>(
    () async => OnboardingLocalDataSourceImpl(
      await getIt.getAsync<SharedPreferences>(),
    ),
  );
  getIt.registerSingletonAsync<OnboardingRepository>(
    () async => OnboardingRepositoryImpl(
      local: await getIt.getAsync<OnboardingLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetCurrentStepUseCase>(
    () => GetCurrentStepUseCase(getIt<OnboardingRepository>()),
  );
  getIt.registerLazySingleton<CompleteStepUseCase>(
    () => CompleteStepUseCase(getIt<OnboardingRepository>()),
  );
  getIt.registerLazySingleton<SkipOnboardingUseCase>(
    () => SkipOnboardingUseCase(getIt<OnboardingRepository>()),
  );
  getIt.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      getCurrentStepUseCase: getIt<GetCurrentStepUseCase>(),
      completeStepUseCase: getIt<CompleteStepUseCase>(),
      skipOnboardingUseCase: getIt<SkipOnboardingUseCase>(),
      totalSteps: 4,
    ),
  );

  getIt.registerSingletonAsync<SubscriptionRepository>(
    () async => SubscriptionRepositoryImpl(),
  );
  getIt.registerSingletonAsync<GetPlansUseCase>(
    () async => GetPlansUseCase(await getIt.getAsync<SubscriptionRepository>()),
  );
  getIt.registerSingletonAsync<SubscribeUserUseCase>(
    () async =>
        SubscribeUserUseCase(await getIt.getAsync<SubscriptionRepository>()),
  );
  getIt.registerSingletonAsync<CancelSubscriptionUseCase>(
    () async => CancelSubscriptionUseCase(
      await getIt.getAsync<SubscriptionRepository>(),
    ),
  );
  getIt.registerSingletonAsync<CheckStatusUseCase>(
    () async =>
        CheckStatusUseCase(await getIt.getAsync<SubscriptionRepository>()),
  );
  getIt.registerFactory<SubscriptionsCubit>(
    () => SubscriptionsCubit(getPlansUseCase: getIt<GetPlansUseCase>()),
  );

  // Pre-warm use cases required by app.dart BlocProviders (all lazy async singletons used at startup).
  getIt.getAsync<GetSettingsUseCase>();
  getIt.getAsync<UpdateSettingsUseCase>();
  getIt.getAsync<ResetSettingsUseCase>();
  getIt.getAsync<SetAppModeUseCase>();
  getIt.getAsync<GetStatisticsUseCase>();
  getIt.getAsync<GetRecurringExpensesUseCase>();
  getIt.getAsync<CreateRecurringExpenseUseCase>();
  getIt.getAsync<UpdateRecurringExpenseUseCase>();
  getIt.getAsync<DeleteRecurringExpenseUseCase>();
  getIt.getAsync<EnableRecurringReminderUseCase>();
  getIt.getAsync<DisableRecurringReminderUseCase>();
  getIt.getAsync<GetRecurringRemindersEnabledUseCase>();
  getIt.getAsync<SetRecurringRemindersEnabledUseCase>();
  getIt.getAsync<RescheduleAllRecurringRemindersUseCase>();
  getIt.getAsync<ShowTestRecurringReminderUseCase>();

  await getIt.allReady();
}
