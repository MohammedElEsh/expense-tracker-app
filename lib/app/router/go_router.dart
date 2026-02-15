import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/app/router/route_names.dart';
import 'package:expense_tracker/app/router/route_guards.dart';

export 'package:expense_tracker/app/router/route_names.dart';
import 'package:expense_tracker/app/pages/splash_screen.dart';
import 'package:expense_tracker/app/pages/main_screen.dart';

import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/business_signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/personal_signup_screen.dart';

import 'package:expense_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:expense_tracker/features/statistics/presentation/pages/statistics_screen.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_management_screen.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_screen.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';

import 'package:expense_tracker/features/settings/presentation/pages/settings_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/account_details_screen.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';

import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expenses_screen.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expense_details_screen.dart';
import 'package:expense_tracker/features/recurring_expenses/domain/entities/recurring_expense_entity.dart';

import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_details_screen.dart';

import 'package:expense_tracker/features/projects/presentation/pages/projects_screen.dart';
import 'package:expense_tracker/features/projects/presentation/pages/project_details_screen.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';

import 'package:expense_tracker/features/vendors/presentation/pages/vendors_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendor_details_screen.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';

import 'package:expense_tracker/features/companies/presentation/pages/companies_screen.dart';
import 'package:expense_tracker/features/companies/presentation/pages/company_details_screen.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';

import 'package:expense_tracker/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:expense_tracker/features/subscriptions/presentation/pages/subscription_screen.dart';
import 'package:expense_tracker/features/ocr/presentation/pages/ocr_scanner_screen.dart' show OCRScannerScreen;
import 'package:expense_tracker/features/users/presentation/pages/user_management_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/add_user_screen.dart';
import 'package:expense_tracker/features/users/presentation/pages/edit_user_screen.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: redirectGuard,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const SimpleLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupBusiness,
      builder: (context, state) => const BusinessSignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.signupPersonal,
      builder: (context, state) => const PersonalSignupScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          MainScreen(currentLocation: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.statistics,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatisticsScreen()),
        ),
        GoRoute(
          path: AppRoutes.budgets,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: BudgetManagementScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.budgetDetails,
      builder: (context, state) {
        final map = state.extra as Map<String, dynamic>?;
        if (map == null) return const SizedBox.shrink();
        return BudgetDetailsScreen(
          budget: map['budget'] as Budget,
          spent: map['spent'] as double,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.accounts,
      builder: (context, state) => const AccountsScreen(),
    ),
    GoRoute(
      path: AppRoutes.accountDetails,
      builder: (context, state) {
        final account = state.extra as AccountEntity?;
        if (account == null) return const SizedBox.shrink();
        return AccountDetailsScreen(account: account);
      },
    ),
    GoRoute(
      path: AppRoutes.recurringExpenses,
      builder: (context, state) => const RecurringExpensesScreen(),
    ),
    GoRoute(
      path: AppRoutes.recurringExpenseDetails,
      builder: (context, state) {
        final entity = state.extra as RecurringExpenseEntity?;
        if (entity == null) return const SizedBox.shrink();
        return RecurringExpenseDetailsScreen(recurringExpense: entity);
      },
    ),
    GoRoute(
      path: AppRoutes.expenseDetails,
      builder: (context, state) {
        final expense = state.extra as Expense?;
        if (expense == null) return const SizedBox.shrink();
        return ExpenseDetailsScreen(expense: expense);
      },
    ),
    GoRoute(
      path: AppRoutes.projects,
      builder: (context, state) => const ProjectsScreen(),
    ),
    GoRoute(
      path: AppRoutes.projectDetails,
      builder: (context, state) {
        final project = state.extra as ProjectEntity?;
        if (project == null) return const SizedBox.shrink();
        return ProjectDetailsScreen(project: project);
      },
    ),
    GoRoute(
      path: AppRoutes.vendors,
      builder: (context, state) => const VendorsScreen(),
    ),
    GoRoute(
      path: AppRoutes.vendorDetails,
      builder: (context, state) {
        final vendor = state.extra as VendorEntity?;
        if (vendor == null) return const SizedBox.shrink();
        return VendorDetailsScreen(vendor: vendor);
      },
    ),
    GoRoute(
      path: AppRoutes.companies,
      builder: (context, state) => const CompaniesScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyDetails,
      builder: (context, state) {
        final company = state.extra as CompanyEntity?;
        if (company == null) return const SizedBox.shrink();
        return CompanyDetailsScreen(company: company);
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.subscription,
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: AppRoutes.ocrScanner,
      builder: (context, state) => const OCRScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.userManagement,
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.addUser,
      builder: (context, state) => const AddUserScreen(),
    ),
    GoRoute(
      path: AppRoutes.editUser,
      builder: (context, state) {
        final user = state.extra as UserEntity?;
        if (user == null) return const SizedBox.shrink();
        return EditUserScreen(userEntity: user);
      },
    ),
  ],
);
