// ✅ User Context Manager - Central handler for user/role context changes
// Ensures complete state isolation when user or role changes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

/// Central manager for handling user context changes
/// Clears all state when user or role changes to ensure data isolation
class UserContextManager {
  static final UserContextManager _instance = UserContextManager._internal();
  factory UserContextManager() => _instance;
  UserContextManager._internal();

  /// Previous user context (userId + role) for change detection
  String? _previousUserContext;

  /// Handle user context change
  /// Called on login and role changes
  /// [userId] - New user ID
  /// [role] - New user role
  /// [companyId] - Company ID (optional, for business mode)
  /// [context] - BuildContext (optional, required for BLoC reset)
  Future<void> onUserContextChanged({
    required String? userId,
    required UserRole? role,
    String? companyId,
    BuildContext? context,
  }) async {
    final currentContext = _buildContextKey(userId, role, companyId);

    // Check if context actually changed
    if (_previousUserContext == currentContext) {
      debugPrint('🔄 User context unchanged, skipping state clear');
      return;
    }

    debugPrint('🔐 User context changed - Clearing all state');
    debugPrint('   Previous: $_previousUserContext');
    debugPrint('   Current: $currentContext');

    // Always clear all cached data in services (no context needed)
    await _clearAllCaches();

    // Reset BLoC states if context is available
    if (context != null) {
      _resetAllBlocStates(context);
    } else {
      debugPrint(
        '⚠️ BuildContext not available - BLoC states will be reset on next use',
      );
    }

    // Update previous context
    _previousUserContext = currentContext;

    debugPrint('✅ User context changed - All state cleared');
  }

  /// Build context key from user ID, role, and company ID
  String _buildContextKey(String? userId, UserRole? role, String? companyId) {
    return '${userId ?? 'null'}_${role?.name ?? 'null'}_${companyId ?? 'null'}';
  }

  /// Clear all service caches
  Future<void> _clearAllCaches() async {
    try {
      debugPrint('🗑️ Clearing all service caches...');

      // Clear AccountService cache
      serviceLocator.accountService.clearCache();

      // Clear BudgetService cache
      serviceLocator.budgetService.clearCache();

      // Clear ExpenseApiService cache
      serviceLocator.expenseApiService.clearCache();

      // Clear ProjectApiService cache
      serviceLocator.projectService.clearCache();

      // Clear RecurringExpenseApiService cache
      serviceLocator.recurringExpenseService.clearCache();

      // Clear VendorService cache
      serviceLocator.vendorService.clearCache();

      // Clear CompanyApiService cache
      serviceLocator.companyService.clearCache();

      debugPrint('✅ All service caches cleared');
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
    }
  }

  /// Reset all BLoC states to initial empty state
  /// Uses try-catch to gracefully handle missing BLoCs
  void _resetAllBlocStates(BuildContext context) {
    try {
      debugPrint('🔄 Resetting all BLoC states...');

      // Reset AccountCubit
      _tryResetBloc<AccountCubit>(
        context,
        (cubit) => cubit.initializeAccounts(),
        'AccountCubit',
      );

      // Note: Other BLoCs will be reset when Load* events are called
      // This is safer than trying to directly reset their state
      // The cache clearing above ensures old data won't be reused

      debugPrint('✅ All BLoC states reset initiated');
    } catch (e) {
      debugPrint('❌ Error resetting BLoC states: $e');
    }
  }

  /// Helper to safely reset a BLoC
  void _tryResetBloc<T extends StateStreamable>(
    BuildContext context,
    void Function(T bloc) resetAction,
    String blocName,
  ) {
    try {
      final bloc = context.read<T>();
      resetAction(bloc);
      debugPrint('   ✓ $blocName reset');
    } catch (e) {
      // BLoC not in widget tree - this is okay, will be reset on next use
      debugPrint('   ⚠ $blocName not in widget tree (will reset on next use)');
    }
  }

  /// Clear context (for logout)
  void clearContext() {
    debugPrint('🚪 Clearing user context (logout)');
    _previousUserContext = null;
  }

  /// Check if user context has changed
  bool hasContextChanged(String? userId, UserRole? role, String? companyId) {
    final currentContext = _buildContextKey(userId, role, companyId);
    return _previousUserContext != currentContext;
  }
}

/// Global instance
final userContextManager = UserContextManager();
