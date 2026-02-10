// Project Dialog - Priority Slider Widget
import 'package:flutter/material.dart';

class ProjectPrioritySlider extends StatelessWidget {
  final int priority;
  final bool isRTL;
  final Function(double) onChanged;

  const ProjectPrioritySlider({
    super.key,
    required this.priority,
    required this.isRTL,
    required this.onChanged,
  });

  String _getPriorityLabel(int priority) {
    if (!isRTL) {
      switch (priority) {
        case 1:
          return 'Low';
        case 2:
          return 'Medium-Low';
        case 3:
          return 'Medium';
        case 4:
          return 'Medium-High';
        case 5:
          return 'High';
        default:
          return 'Medium';
      }
    } else {
      switch (priority) {
        case 1:
          return 'منخفضة';
        case 2:
          return 'متوسطة-منخفضة';
        case 3:
          return 'متوسطة';
        case 4:
          return 'متوسطة-عالية';
        case 5:
          return 'عالية';
        default:
          return 'متوسطة';
      }
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isRTL ? 'الأولوية' : 'Priority',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getPriorityColor(priority)),
              ),
              child: Text(
                _getPriorityLabel(priority),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getPriorityColor(priority),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: priority.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _getPriorityLabel(priority),
          activeColor: _getPriorityColor(priority),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
