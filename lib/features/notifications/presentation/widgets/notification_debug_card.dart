import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminder_item.dart';
import 'package:flutter/material.dart';

/// Debug info card (only shown when debug mode is toggled on).
class NotificationDebugCard extends StatelessWidget {
  const NotificationDebugCard({
    super.key,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shadowColor: Colors.black.withValues(alpha: isDarkMode ? 0.22 : 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Uses recurring expenses data to render upcoming reminders (next $defaultUpcomingDays days)\n'
              '• Not a notification history feed\n'
              '• System notifications are scheduled separately via flutter_local_notifications',
              style: TextStyle(fontSize: 12.5, color: secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
