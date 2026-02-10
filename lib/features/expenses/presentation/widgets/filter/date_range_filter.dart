// Expense Filter - Date Range Filter Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTimeRange? dateRange;
  final bool isRTL;
  final Function(DateTimeRange?) onDateRangeChanged;

  const DateRangeFilter({
    super.key,
    required this.dateRange,
    required this.isRTL,
    required this.onDateRangeChanged,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'نطاق التاريخ' : 'Date Range',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDateRange(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateRange != null
                          ? '${DateFormat('MMM dd, yyyy').format(dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(dateRange!.end)}'
                          : (isRTL ? 'اختر نطاق التاريخ' : 'Select date range'),
                      style: TextStyle(
                        color:
                            dateRange != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  if (dateRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => onDateRangeChanged(null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
