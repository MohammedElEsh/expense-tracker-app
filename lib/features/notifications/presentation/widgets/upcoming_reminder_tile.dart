import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminder_item.dart';
import 'package:flutter/material.dart';

/// A single list-tile for an [UpcomingItem] in the upcoming reminders list.
class UpcomingReminderTile extends StatelessWidget {
  const UpcomingReminderTile({
    super.key,
    required this.item,
    required this.isEnabled,
    required this.isRTL,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.onTap,
  });

  final UpcomingItem item;
  final bool isEnabled;
  final bool isRTL;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          item.isToday
              ? Icons.today_rounded
              : item.isTomorrow
              ? Icons.event_available_rounded
              : Icons.schedule_rounded,
          color: primaryColor,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(fontWeight: FontWeight.w700, color: primaryTextColor),
      ),
      subtitle: Text(
        '${item.relativeLabel} • ${item.dateLabel}',
        style: TextStyle(fontSize: 12.8, color: secondaryTextColor),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.amountLabel,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isEnabled
                ? (isRTL ? 'مُفعّل' : 'Enabled')
                : (isRTL ? 'متوقف' : 'Off'),
            style: TextStyle(
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
              color: isEnabled ? primaryColor : secondaryTextColor,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
