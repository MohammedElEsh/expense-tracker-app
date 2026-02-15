import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Maps data from API/local to domain entities. Currently uses mock data.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl();

  static List<SubscriptionPlan> get _mockPlans => [
        const SubscriptionPlan(
          id: 'free',
          title: 'Free',
          price: 0,
          features: ['Up to 50 expenses', 'Basic reports', '1 account'],
        ),
        const SubscriptionPlan(
          id: 'pro',
          title: 'Pro',
          price: 9.99,
          features: [
            'Unlimited expenses',
            'Advanced reports',
            'Multiple accounts',
            'Export data',
          ],
        ),
        const SubscriptionPlan(
          id: 'premium',
          title: 'Premium',
          price: 19.99,
          features: [
            'Everything in Pro',
            'Priority support',
            'Recurring reminders',
            'Team features',
          ],
        ),
      ];

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    return _mockPlans;
  }

  @override
  Future<void> subscribeUser(String planId) async {
    // TODO: integrate with payment/API when feature is live
  }

  @override
  Future<void> cancelSubscription() async {
    // TODO: integrate with API when feature is live
  }

  @override
  Future<SubscriptionStatus> checkStatus() async {
    // TODO: integrate with API when feature is live
    return const SubscriptionStatus(planId: 'free', isActive: true);
  }
}
