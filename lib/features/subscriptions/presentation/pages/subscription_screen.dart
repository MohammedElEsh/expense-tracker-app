import 'package:expense_tracker/features/subscriptions/presentation/pages/subscription_plans_page.dart';
import 'package:flutter/material.dart';

/// App-level subscription screen (used by router/drawer).
/// Delegates to [SubscriptionPlansPage].
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SubscriptionPlansPage();
  }
}
