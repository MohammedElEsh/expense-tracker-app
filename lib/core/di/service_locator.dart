import 'package:expense_tracker/core/network/api_service.dart';
import 'package:expense_tracker/core/network/dio_client.dart';
import 'package:expense_tracker/core/notifications/recurring_expense_notification_service.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/features/accounts/data/datasources/account_service.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/domain/usecases/check_user_status_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_business_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/register_personal_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:expense_tracker/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_service.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_api_service.dart';
import 'package:expense_tracker/features/projects/data/datasources/project_api_service.dart';
import 'package:expense_tracker/features/recurring_expenses/data/datasources/recurring_expense_api_service.dart';
import 'package:expense_tracker/features/vendors/data/datasources/vendor_service.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_api_service.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/users/data/datasources/user_api_service.dart';

/// Service Locator for dependency injection
/// Provides singleton instances of core services
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core services
  late final PrefHelper prefHelper;
  late final DioClient dioClient;
  late final ApiService apiService;

  // Feature services
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;
  late final AccountService accountService;
  late final BudgetService budgetService;
  late final ExpenseApiService expenseApiService;
  late final ProjectApiService projectService;
  late final RecurringExpenseApiService recurringExpenseService;
  late final RecurringExpenseNotificationService
  recurringExpenseNotificationService;
  late final VendorService vendorService;
  late final SettingsApiService settingsApiService;
  late final CompanyApiService companyService;
  late final UserApiService userApiService;

  // UseCases
  late final LoginUseCase loginUseCase;
  late final LogoutUseCase logoutUseCase;
  late final RegisterPersonalUseCase registerPersonalUseCase;
  late final RegisterBusinessUseCase registerBusinessUseCase;
  late final CheckUserStatusUseCase checkUserStatusUseCase;
  late final VerifyEmailUseCase verifyEmailUseCase;
  late final ResendVerificationUseCase resendVerificationUseCase;

  /// Initialize all services
  /// Call this once at app startup
  Future<void> init() async {
    // Initialize core services
    prefHelper = PrefHelper();
    dioClient = DioClient(prefHelper);
    apiService = ApiService(dioClient.dio);

    // Initialize feature services
    authRemoteDataSource = AuthRemoteDataSource(
      apiService: apiService,
      prefHelper: prefHelper,
    );

    authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

    // Initialize AccountService
    accountService = AccountService(
      apiService: apiService,
      prefHelper: prefHelper,
    );

    // Initialize BudgetService
    budgetService = BudgetService(apiService: apiService);

    // Initialize ExpenseApiService
    expenseApiService = ExpenseApiService(apiService: apiService);

    // Initialize ProjectApiService
    projectService = ProjectApiService(apiService: apiService);

    // Initialize RecurringExpenseApiService
    recurringExpenseService = RecurringExpenseApiService(
      apiService: apiService,
    );

    // Initialize RecurringExpenseNotificationService (local notifications)
    recurringExpenseNotificationService = RecurringExpenseNotificationService();
    await recurringExpenseNotificationService.initialize();

    // Initialize VendorService
    vendorService = VendorService(apiService: apiService);

    // Initialize SettingsApiService
    settingsApiService = SettingsApiService(apiService: apiService);

    // Initialize CompanyApiService
    companyService = CompanyApiService(apiService: apiService);

    // Initialize UserApiService
    userApiService = UserApiService(apiService: apiService);

    // Initialize UseCases
    loginUseCase = LoginUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    registerPersonalUseCase = RegisterPersonalUseCase(authRepository);
    registerBusinessUseCase = RegisterBusinessUseCase(authRepository);
    checkUserStatusUseCase = CheckUserStatusUseCase(authRepository);
    verifyEmailUseCase = VerifyEmailUseCase(authRepository);
    resendVerificationUseCase = ResendVerificationUseCase(authRepository);
  }

  /// Reset all services (useful for testing or logout)
  Future<void> reset() async {
    await prefHelper.clearAll();
    dioClient.resetInterceptors();
    accountService.clearCache();
    budgetService.clearCache();
    expenseApiService.clearCache();
    projectService.clearCache();
    recurringExpenseService.clearCache();
    vendorService.clearCache();
    companyService.clearCache();
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();
