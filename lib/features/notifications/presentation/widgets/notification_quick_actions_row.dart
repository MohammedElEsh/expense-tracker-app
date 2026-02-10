import 'package:expense_tracker/features/notifications/presentation/widgets/notification_action_button.dart';
import 'package:flutter/material.dart';

/// Row of quick-action buttons (Test & Reschedule).
class NotificationQuickActionsRow extends StatelessWidget {
  const NotificationQuickActionsRow({
    super.key,
    required this.isRTL,
    required this.primaryColor,
    required this.isDisabled,
    required this.onTestTap,
    required this.onRescheduleTap,
  });

  final bool isRTL;
  final Color primaryColor;
  final bool isDisabled;
  final VoidCallback onTestTap;
  final VoidCallback onRescheduleTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NotificationActionButton(
            icon: Icons.notifications_rounded,
            title: isRTL ? 'اختبار' : 'Test',
            subtitle: isRTL ? 'إشعار فوري' : 'Send now',
            color: primaryColor,
            isDisabled: isDisabled,
            onTap: onTestTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NotificationActionButton(
            icon: Icons.schedule_rounded,
            title: isRTL ? 'إعادة جدولة' : 'Reschedule',
            subtitle: isRTL ? 'كل التذكيرات' : 'All reminders',
            color: primaryColor,
            isDisabled: isDisabled,
            onTap: onRescheduleTap,
          ),
        ),
      ],
    );
  }
}
