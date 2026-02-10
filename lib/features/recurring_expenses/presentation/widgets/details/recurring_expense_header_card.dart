// Recurring Expense Details - Header Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class RecurringExpenseHeaderCard extends StatelessWidget {
  final RecurringExpense recurringExpense;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const RecurringExpenseHeaderCard({
    super.key,
    required this.recurringExpense,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(recurringExpense.category),
            _getCategoryColor(recurringExpense.category).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor(
              recurringExpense.category,
            ).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(recurringExpense.category),
                  size: isDesktop ? 32 : 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recurringExpense.notes.isNotEmpty
                          ? recurringExpense.notes
                          : recurringExpense.category,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recurringExpense.category,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  recurringExpense.isActive
                      ? (isRTL ? 'نشط' : 'Active')
                      : (isRTL ? 'غير نشط' : 'Inactive'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.white.withValues(alpha: 0.9),
                size: isDesktop ? 24 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${recurringExpense.amount.toStringAsFixed(2)} ${settings.currencySymbol}',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // استخدام ألوان أعمق وأكثر حيوية للـ gradient
    switch (category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Colors.orange.shade700;
      case 'transport':
      case 'مواصلات':
        return Colors.blue.shade700;
      case 'entertainment':
      case 'ترفيه':
        return Colors.purple.shade700;
      case 'shopping':
      case 'تسوق':
        return Colors.pink.shade700;
      case 'health':
      case 'صحة':
        return Colors.green.shade700;
      case 'education':
      case 'تعليم':
        return Colors.indigo.shade700;
      case 'bills':
      case 'فواتير':
        return Colors.red.shade700;
      case 'salary':
      case 'رواتب':
        return Colors.teal.shade700;
      case 'office supplies':
      case 'مستلزمات مكتبية':
        return Colors.brown.shade700;
      case 'marketing':
      case 'تسويق':
        return Colors.amber.shade700;
      case 'travel':
      case 'سفر':
        return Colors.cyan.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'طعام':
        return Icons.restaurant;
      case 'transport':
      case 'مواصلات':
        return Icons.directions_car;
      case 'entertainment':
      case 'ترفيه':
        return Icons.movie;
      case 'shopping':
      case 'تسوق':
        return Icons.shopping_bag;
      case 'health':
      case 'صحة':
        return Icons.health_and_safety;
      case 'education':
      case 'تعليم':
        return Icons.school;
      case 'bills':
      case 'فواتير':
        return Icons.receipt;
      case 'salary':
      case 'رواتب':
        return Icons.people;
      case 'office supplies':
      case 'مستلزمات مكتبية':
        return Icons.business;
      case 'marketing':
      case 'تسويق':
        return Icons.campaign;
      case 'travel':
      case 'سفر':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }
}
