import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Use case: subscribe the current user to a plan.
class SubscribeUserUseCase {
  final SubscriptionRepository repository;

  SubscribeUserUseCase(this.repository);

  Future<void> call(String planId) => repository.subscribeUser(planId);
}
