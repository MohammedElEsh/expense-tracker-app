import 'package:flutter/material.dart';
import 'package:expense_tracker/features/budgets/data/models/budget.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/constants/categories.dart';

class BudgetCategoryCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final SettingsState settings;
  final bool isRTL;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BudgetCategoryCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.settings,
    required this.isRTL,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;
    final remaining = budget.limit - spent;
    final isOverBudget = spent > budget.limit;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: _getCategoryColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Categories.getDisplayName(budget.category, isRTL),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${budget.limit.toStringAsFixed(2)} ${settings.currencySymbol}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // if (onDelete != null)
                    // IconButton(
                    //   icon: const Icon(Icons.delete),
                    //   color: Colors.red,
                    //   onPressed: onDelete,
                    // ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.red : Colors.green,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isRTL ? 'المتبقي' : 'Remaining'}: ${remaining.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? Colors.red : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (budget.category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Colors.orange;
      case 'transport':
      case 'مواصلات':
        return Colors.blue;
      case 'shopping':
      case 'تسوق':
        return Colors.purple;
      case 'entertainment':
      case 'ترفيه':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (budget.category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Icons.restaurant;
      case 'transport':
      case 'مواصلات':
        return Icons.directions_car;
      case 'shopping':
      case 'تسوق':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'ترفيه':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
}
