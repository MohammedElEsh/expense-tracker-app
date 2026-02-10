// Expense Filter - Filter Summary Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterSummary extends StatelessWidget {
  final int filteredCount;
  final int totalCount;
  final double totalAmount;
  final String currencySymbol;
  final bool isRTL;
  final VoidCallback onResetFilters;
  final bool hasActiveFilters;

  const FilterSummary({
    super.key,
    required this.filteredCount,
    required this.totalCount,
    required this.totalAmount,
    required this.currencySymbol,
    required this.isRTL,
    required this.onResetFilters,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'النتائج' : 'Results',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    isRTL
                        ? '$filteredCount من $totalCount مصروف'
                        : '$filteredCount of $totalCount expenses',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isRTL ? 'الإجمالي' : 'Total',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '$currencySymbol ${NumberFormat('#,##0.00').format(totalAmount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onResetFilters,
                icon: const Icon(Icons.clear_all),
                label: Text(isRTL ? 'إعادة تعيين الفلاتر' : 'Reset Filters'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
