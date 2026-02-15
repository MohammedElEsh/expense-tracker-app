// Notifications Feature - UI only calls NotificationsCubit; no direct use cases or services.
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/coming_soon_section.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_quick_actions_row.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/recurring_reminders_toggle_card.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminders_section.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsCubit>(
      create: (_) => getIt<NotificationsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, notifState) {
              if (notifState.recurringRemindersEnabled == null &&
                  notifState is NotificationsLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<NotificationsCubit>().load();
                });
              }
              final isRTL = settings.language == 'ar';
              final enabled = notifState.recurringRemindersEnabled ?? true;
              final isApplyingToggle = notifState.isApplyingToggle;

              return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: settings.surfaceColor,
            appBar: AppBar(
              backgroundColor: settings.primaryColor,
              foregroundColor:
                  settings.isDarkMode ? Colors.black : Colors.white,
              elevation: 0,
              title: Text(
                isRTL ? 'الإشعارات' : 'Notifications',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: isRTL ? 'تحديث الجدولة' : 'Reschedule',
                  onPressed: isApplyingToggle
                      ? null
                      : () => context.read<NotificationsCubit>().rescheduleAll(),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    settings.primaryColor.withValues(alpha: 0.06),
                    settings.surfaceColor,
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  RecurringRemindersToggleCard(
                    enabled: notifState.recurringRemindersEnabled,
                    isLoading: isApplyingToggle,
                    onChanged: (value) =>
                        context.read<NotificationsCubit>().setRecurringRemindersEnabled(value),
                    isRTL: isRTL,
                    primaryColor: settings.primaryColor,
                    primaryTextColor: settings.primaryTextColor,
                    secondaryTextColor: settings.secondaryTextColor,
                    isDarkMode: settings.isDarkMode,
                  ),
                  const SizedBox(height: 14),
                  NotificationQuickActionsRow(
                    isRTL: isRTL,
                    primaryColor: settings.primaryColor,
                    isDisabled: isApplyingToggle,
                    onTestTap: () => _sendTestNow(context, settings, isRTL),
                    onRescheduleTap: () =>
                        context.read<NotificationsCubit>().rescheduleAll(),
                  ),
                  const SizedBox(height: 18),
                  UpcomingRemindersSection(
                    remindersEnabled: enabled,
                    showDebug: _showDebug,
                    isRTL: isRTL,
                    primaryColor: settings.primaryColor,
                    primaryTextColor: settings.primaryTextColor,
                    secondaryTextColor: settings.secondaryTextColor,
                    isDarkMode: settings.isDarkMode,
                  ),
                  const SizedBox(height: 18),
                  ComingSoonSection(
                    isRTL: isRTL,
                    primaryColor: settings.primaryColor,
                    primaryTextColor: settings.primaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendTestNow(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
  ) async {
    await context.read<NotificationsCubit>().sendTest();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'تم إرسال إشعار تجريبي' : 'Test notification sent',
          ),
          backgroundColor: settings.primaryColor,
        ),
      );
    }
  }
}
