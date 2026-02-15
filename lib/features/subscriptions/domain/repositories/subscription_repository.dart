import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_status.dart';

/// Abstract repository for subscription plans and user subscription state.
abstract class SubscriptionRepository {
  /// Get available subscription plans (from API or local).
  Future<List<SubscriptionPlan>> getPlans();

  /// Subscribe the current user to a plan.
  Future<void> subscribeUser(String planId);

  /// Cancel the current user's subscription.
  Future<void> cancelSubscription();

  /// Check current subscription status.
  Future<SubscriptionStatus> checkStatus();
}
