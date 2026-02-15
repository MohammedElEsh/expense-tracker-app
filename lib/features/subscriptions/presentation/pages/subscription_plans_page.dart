import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import 'package:expense_tracker/features/subscriptions/presentation/cubit/subscriptions_state.dart';
import 'package:expense_tracker/features/subscriptions/presentation/widgets/plan_card.dart';
import 'package:expense_tracker/features/subscriptions/presentation/widgets/subscribe_button.dart';

class SubscriptionPlansPage extends StatefulWidget {
  const SubscriptionPlansPage({super.key});

  @override
  State<SubscriptionPlansPage> createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionsCubit>().loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'الخطط' : 'Subscription plans'),
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          if (state is SubscriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SubscriptionsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<SubscriptionsCubit>().loadPlans(),
                      child: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is SubscriptionsLoaded || state is SubscriptionsSelected) {
            final plans = state is SubscriptionsLoaded
                ? state.plans
                : (state as SubscriptionsSelected).plans;
            final selected = state is SubscriptionsSelected
                ? state.selected
                : null;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: plans.map((plan) {
                final isSelected = selected?.id == plan.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PlanCard(
                    plan: plan,
                    isSelected: isSelected,
                    onSelect: () =>
                        context.read<SubscriptionsCubit>().selectPlan(plan),
                    subscribeButton: SubscribeButton(
                      label: isRTL ? 'اختر الخطة' : 'Subscribe',
                      onPressed: () =>
                          context.read<SubscriptionsCubit>().selectPlan(plan),
                    ),
                  ),
                );
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
