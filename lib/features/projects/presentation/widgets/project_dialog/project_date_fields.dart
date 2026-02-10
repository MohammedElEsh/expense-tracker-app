// Project Dialog - Date Fields Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDateFields extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRTL;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  const ProjectDateFields({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.isRTL,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start Date
        Expanded(
          child: InkWell(
            onTap: onStartDateTap,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isRTL ? 'تاريخ البدء *' : 'Start Date *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                DateFormat('MMM dd, yyyy').format(startDate),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // End Date
        Expanded(
          child: InkWell(
            onTap: onEndDateTap,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isRTL ? 'تاريخ الانتهاء' : 'End Date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.event),
              ),
              child: Text(
                endDate != null
                    ? DateFormat('MMM dd, yyyy').format(endDate!)
                    : (isRTL ? 'لم يحدد' : 'Not set'),
                style: TextStyle(
                  fontSize: 14,
                  color: endDate != null ? null : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
