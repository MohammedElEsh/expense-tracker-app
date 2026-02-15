/// Route path constants (single source of truth).
class AppRoutes {
  AppRoutes._();

  // Startup & Auth
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupBusiness = '/signup/business';
  static const String signupPersonal = '/signup/personal';

  // Main shell (tabs)
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';

  // Feature routes
  static const String budgetDetails = '/budgets/details';
  static const String accounts = '/accounts';
  static const String accountDetails = '/accounts/details';
  static const String recurringExpenses = '/recurring-expenses';
  static const String recurringExpenseDetails = '/recurring-expenses/details';
  static const String expenseDetails = '/expenses/details';
  static const String projects = '/projects';
  static const String projectDetails = '/projects/details';
  static const String vendors = '/vendors';
  static const String vendorDetails = '/vendors/details';
  static const String companies = '/companies';
  static const String companyDetails = '/companies/details';
  static const String notifications = '/notifications';
  static const String subscription = '/subscription';
  static const String ocrScanner = '/ocr-scanner';
  static const String userManagement = '/users';
  static const String addUser = '/users/add';
  static const String editUser = '/users/edit';
}
