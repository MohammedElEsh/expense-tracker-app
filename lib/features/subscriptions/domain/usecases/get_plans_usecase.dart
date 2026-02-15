import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Use case: get available subscription plans.
class GetPlansUseCase {
  final SubscriptionRepository repository;

  GetPlansUseCase(this.repository);

  Future<List<SubscriptionPlan>> call() => repository.getPlans();
}
