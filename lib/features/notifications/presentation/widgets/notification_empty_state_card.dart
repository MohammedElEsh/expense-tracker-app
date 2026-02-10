import 'package:flutter/material.dart';

/// Card shown when there are no upcoming reminders.
class NotificationEmptyStateCard extends StatelessWidget {
  const NotificationEmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: isDarkMode ? 0.22 : 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.inbox_outlined, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.8, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
