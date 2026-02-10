// Add Expense - Date Picker Field Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final bool isRTL;
  final Function(DateTime) onDateChanged;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.isRTL,
    required this.onDateChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null) {
      // Set time to start of day (00:00:00) - user can only select date, not time
      final dateOnly = DateTime(picked.year, picked.month, picked.day);
      if (dateOnly != DateTime(selectedDate.year, selectedDate.month, selectedDate.day)) {
        onDateChanged(dateOnly);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRTL ? 'التاريخ' : 'Date',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
