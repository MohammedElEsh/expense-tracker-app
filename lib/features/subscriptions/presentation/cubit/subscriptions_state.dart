import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';

sealed class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionsLoading extends SubscriptionsState {
  const SubscriptionsLoading();
}

final class SubscriptionsLoaded extends SubscriptionsState {
  final List<SubscriptionPlan> plans;

  const SubscriptionsLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

final class SubscriptionsSelected extends SubscriptionsState {
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan selected;

  const SubscriptionsSelected({required this.plans, required this.selected});

  @override
  List<Object?> get props => [plans, selected];
}

final class SubscriptionsError extends SubscriptionsState {
  final String message;

  const SubscriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}
