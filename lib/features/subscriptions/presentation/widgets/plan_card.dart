import 'package:flutter/material.dart';
import 'package:expense_tracker/features/subscriptions/domain/entities/subscription_plan.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onSelect,
    this.subscribeButton,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onSelect;
  final Widget? subscribeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: theme.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.price == 0
                    ? 'Free'
                    : '\$${plan.price.toStringAsFixed(2)}/mo',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...plan.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, size: 18, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(f, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              ),
              if (subscribeButton != null) ...[
                const SizedBox(height: 16),
                subscribeButton!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
