import 'package:flutter/material.dart';

/// Card with a [SwitchListTile] for toggling recurring expense reminders.
class RecurringRemindersToggleCard extends StatelessWidget {
  const RecurringRemindersToggleCard({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.onChanged,
    required this.isRTL,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

  /// Current toggle state (`null` = still loading).
  final bool? enabled;

  /// Whether a toggle operation is in progress.
  final bool isLoading;

  final ValueChanged<bool>? onChanged;
  final bool isRTL;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final value = enabled ?? true;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SwitchListTile(
          value: value,
          onChanged: (enabled == null || isLoading) ? null : onChanged,
          title: Text(
            isRTL ? 'تذكير بالمصروفات المتكررة' : 'Recurring expense reminders',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          subtitle: Text(
            isRTL
                ? 'سيستم إشعارات على موعد المصروف (مثلاً 9:00 ص)'
                : 'System reminders at due time (e.g. 9:00 AM)',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          secondary: Icon(Icons.repeat_rounded, color: primaryColor),
          activeColor: primaryColor,
        ),
      ),
    );
  }
}
