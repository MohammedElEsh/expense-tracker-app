import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Use case: cancel the current user's subscription.
class CancelSubscriptionUseCase {
  final SubscriptionRepository repository;

  CancelSubscriptionUseCase(this.repository);

  Future<void> call() => repository.cancelSubscription();
}
