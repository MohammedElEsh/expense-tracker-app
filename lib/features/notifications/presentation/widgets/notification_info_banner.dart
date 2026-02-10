import 'package:flutter/material.dart';

/// A coloured banner that displays an icon + message (e.g. "Reminders off").
class NotificationInfoBanner extends StatelessWidget {
  const NotificationInfoBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.primaryColor,
    required this.primaryTextColor,
  });

  final IconData icon;
  final String text;
  final Color primaryColor;
  final Color primaryTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: primaryColor.withValues(alpha: 0.10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
