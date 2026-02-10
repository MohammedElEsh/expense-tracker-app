import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetMonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final bool isRTL;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const BudgetMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.isRTL,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
            onPressed: onPreviousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
