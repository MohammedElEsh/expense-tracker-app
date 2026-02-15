import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:expense_tracker/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Use case: check current subscription status.
class CheckStatusUseCase {
  final SubscriptionRepository repository;

  CheckStatusUseCase(this.repository);

  Future<SubscriptionStatus> call() => repository.checkStatus();
}
