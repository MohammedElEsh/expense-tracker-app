import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:expense_tracker/features/subscriptions/domain/usecases/get_plans_usecase.dart';
import 'package:expense_tracker/features/subscriptions/presentation/cubit/subscriptions_state.dart';

/// Subscriptions Cubit: depends only on use cases; no static or direct service access.
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  SubscriptionsCubit({
    required GetPlansUseCase getPlansUseCase,
  })  : _getPlansUseCase = getPlansUseCase,
        super(const SubscriptionsLoading());

  final GetPlansUseCase _getPlansUseCase;

  Future<void> loadPlans() async {
    emit(const SubscriptionsLoading());
    try {
      final plans = await _getPlansUseCase();
      emit(SubscriptionsLoaded(plans));
    } catch (e, st) {
      emit(SubscriptionsError(e.toString()));
      // ignore: avoid_print
      print('SubscriptionsCubit.loadPlans error: $e $st');
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    final current = state;
    if (current is SubscriptionsLoaded) {
      emit(SubscriptionsSelected(plans: current.plans, selected: plan));
    } else if (current is SubscriptionsSelected) {
      emit(SubscriptionsSelected(plans: current.plans, selected: plan));
    }
  }
}
