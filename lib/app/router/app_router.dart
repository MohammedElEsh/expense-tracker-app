import 'package:flutter/material.dart';
import 'package:expense_tracker/core/widgets/animated_page_route.dart';

// Feature screens
import 'package:expense_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:expense_tracker/features/statistics/presentation/pages/statistics_screen.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_management_screen.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_screen.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/account_details_screen.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expenses_screen.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expense_details_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';
import 'package:expense_tracker/features/projects/presentation/pages/projects_screen.dart';
import 'package:expense_tracker/features/projects/presentation/pages/project_details_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendors_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendor_details_screen.dart';
import 'package:expense_tracker/features/companies/presentation/pages/companies_screen.dart';
import 'package:expense_tracker/features/companies/presentation/pages/company_details_screen.dart';
import 'package:expense_tracker/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:expense_tracker/features/subscription/presentation/pages/subscription_screen.dart';
import 'package:expense_tracker/features/ocr/presentation/pages/ocr_scanner_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/user_management_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/add_user_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/edit_user_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_screen.dart';

// Models needed for route arguments
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';

/// Centralized router that defines all named routes for the application.
class AppRouter {
  // ──────────────────────────────────────────────
  // Route name constants
  // ──────────────────────────────────────────────

  // Auth & Onboarding
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // Main / Home
  static const String home = '/home';

  // Statistics
  static const String statistics = '/statistics';

  // Budgets
  static const String budgets = '/budgets';
  static const String budgetDetails = '/budgets/details';

  // Settings
  static const String settings = '/settings';

  // Accounts
  static const String accounts = '/accounts';
  static const String accountDetails = '/accounts/details';

  // Recurring Expenses
  static const String recurringExpenses = '/recurring-expenses';
  static const String recurringExpenseDetails = '/recurring-expenses/details';

  // Expenses
  static const String expenseDetails = '/expenses/details';

  // Projects
  static const String projects = '/projects';
  static const String projectDetails = '/projects/details';

  // Vendors
  static const String vendors = '/vendors';
  static const String vendorDetails = '/vendors/details';

  // Companies
  static const String companies = '/companies';
  static const String companyDetails = '/companies/details';

  // Notifications
  static const String notifications = '/notifications';

  // Subscription
  static const String subscription = '/subscription';

  // OCR Scanner
  static const String ocrScanner = '/ocr-scanner';

  // User Management
  static const String userManagement = '/users';
  static const String addUser = '/users/add';
  static const String editUser = '/users/edit';

  // ──────────────────────────────────────────────
  // Route generation
  // ──────────────────────────────────────────────

  /// Maps route names to screen widgets.
  /// Handles route arguments via [settings.arguments].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Auth & Onboarding ──
      case onboarding:
        return _animatedRoute(const OnboardingScreen(), settings);

      case login:
        return _animatedRoute(const SimpleLoginScreen(), settings);

      case signup:
        return _animatedRoute(const WelcomeScreen(), settings);

      // ── Main / Home ──
      case home:
        return _animatedRoute(const HomeScreen(), settings);

      // ── Statistics ──
      case statistics:
        return _animatedRoute(const StatisticsScreen(), settings);

      // ── Budgets ──
      case budgets:
        return _animatedRoute(const BudgetManagementScreen(), settings);

      case budgetDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return _animatedRoute(
          BudgetDetailsScreen(
            budget: args['budget'] as Budget,
            spent: args['spent'] as double,
          ),
          settings,
        );

      // ── Settings ──
      case AppRouter.settings:
        return _animatedRoute(const SettingsScreen(), settings);

      // ── Accounts ──
      case accounts:
        return _animatedRoute(const AccountsScreen(), settings);

      case accountDetails:
        final account = settings.arguments as Account;
        return _animatedRoute(AccountDetailsScreen(account: account), settings);

      // ── Recurring Expenses ──
      case recurringExpenses:
        return _animatedRoute(const RecurringExpensesScreen(), settings);

      case recurringExpenseDetails:
        final recurringExpense = settings.arguments as RecurringExpense;
        return _animatedRoute(
          RecurringExpenseDetailsScreen(recurringExpense: recurringExpense),
          settings,
        );

      // ── Expenses ──
      case expenseDetails:
        final expense = settings.arguments as Expense;
        return _animatedRoute(ExpenseDetailsScreen(expense: expense), settings);

      // ── Projects ──
      case projects:
        return _animatedRoute(const ProjectsScreen(), settings);

      case projectDetails:
        final project = settings.arguments as Project;
        return _animatedRoute(ProjectDetailsScreen(project: project), settings);

      // ── Vendors ──
      case vendors:
        return _animatedRoute(const VendorsScreen(), settings);

      case vendorDetails:
        final vendor = settings.arguments as Vendor;
        return _animatedRoute(VendorDetailsScreen(vendor: vendor), settings);

      // ── Companies ──
      case companies:
        return _animatedRoute(const CompaniesScreen(), settings);

      case companyDetails:
        final company = settings.arguments as Company;
        return _animatedRoute(CompanyDetailsScreen(company: company), settings);

      // ── Notifications ──
      case notifications:
        return _animatedRoute(const NotificationsScreen(), settings);

      // ── Subscription ──
      case subscription:
        return _animatedRoute(const SubscriptionScreen(), settings);

      // ── OCR Scanner ──
      case ocrScanner:
        return _animatedRoute(const OCRScannerScreen(), settings);

      // ── User Management ──
      case userManagement:
        return _animatedRoute(const UserManagementScreen(), settings);

      case addUser:
        return _animatedRoute(const AddUserScreen(), settings);

      case editUser:
        final user = settings.arguments as Map<String, dynamic>;
        return _animatedRoute(EditUserScreen(user: user), settings);

      // ── Unknown route ──
      default:
        return _errorRoute(settings.name);
    }
  }

  // ──────────────────────────────────────────────
  // Helper: animated route builder
  // ──────────────────────────────────────────────

  /// Wraps a screen widget in an [AnimatedPageRoute] with a slide-up transition.
  static AnimatedPageRoute _animatedRoute(
    Widget child,
    RouteSettings settings, {
    AnimationType animationType = AnimationType.slideAndFade,
  }) {
    return AnimatedPageRoute(child: child, animationType: animationType);
  }

  /// Helper method for navigating to a named route with an animated transition.
  ///
  /// Usage:
  /// ```dart
  /// AppRouter.navigateTo(context, AppRouter.accountDetails, arguments: account);
  /// ```
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Helper method for replacing the current route with a named route.
  static Future<T?> replaceWith<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  // ──────────────────────────────────────────────
  // Error route for unknown routes
  // ──────────────────────────────────────────────

  static MaterialPageRoute _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Route Not Found')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No route defined for "$routeName"',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
