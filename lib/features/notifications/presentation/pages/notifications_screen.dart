// Notifications Feature - Recurring expense reminders toggle + Upcoming reminders list (Option 2)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/coming_soon_section.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_quick_actions_row.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/recurring_reminders_toggle_card.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminders_section.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool? _recurringRemindersEnabled;
  bool _isApplyingToggle = false;
  final bool _showDebug = false;

  // ---------------------- Lifecycle ----------------------

  @override
  void initState() {
    super.initState();
    _loadRecurringRemindersEnabled();
  }

  Future<void> _loadRecurringRemindersEnabled() async {
    final enabled =
        await serviceLocator.prefHelper.getRecurringExpenseRemindersEnabled();
    if (mounted) setState(() => _recurringRemindersEnabled = enabled);
  }

  // ---------------------- Callbacks ----------------------

  Future<void> _onRecurringRemindersChanged(bool value) async {
    if (_isApplyingToggle) return;

    setState(() => _isApplyingToggle = true);

    try {
      await serviceLocator.prefHelper.setRecurringExpenseRemindersEnabled(
        value,
      );
      if (mounted) setState(() => _recurringRemindersEnabled = value);

      if (value) {
        await _requestPermissionsIfNeeded();
      }

      final bloc = context.read<RecurringExpenseCubit>();
      final state = bloc.state;

      if (value) {
        await serviceLocator.recurringExpenseNotificationService.rescheduleAll(
          state.hasLoaded ? state.allRecurringExpenses : [],
        );
      } else {
        await serviceLocator.recurringExpenseNotificationService.rescheduleAll(
          [],
        );
      }
    } finally {
      if (mounted) setState(() => _isApplyingToggle = false);
    }
  }

  Future<void> _requestPermissionsIfNeeded() async {
    final plugin = FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      final android =
          plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await android?.requestNotificationsPermission();
      return;
    }

    if (Platform.isIOS) {
      final ios =
          plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      await ios?.requestPermissions(alert: true, badge: false, sound: true);
    }
  }

  Future<void> _sendTestNow(SettingsState settings, bool isRTL) async {
    await serviceLocator.recurringExpenseNotificationService
        .showTestNotification();
    if (mounted) {
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

  Future<void> _rescheduleAllFromScreen() async {
    final enabled = _recurringRemindersEnabled ?? true;
    final bloc = context.read<RecurringExpenseCubit>();
    final state = bloc.state;

    if (!enabled) {
      await serviceLocator.recurringExpenseNotificationService.rescheduleAll(
        [],
      );
      return;
    }

    await serviceLocator.recurringExpenseNotificationService.rescheduleAll(
      state.hasLoaded ? state.allRecurringExpenses : [],
    );
  }

  // ---------------------- Build ----------------------

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final enabled = _recurringRemindersEnabled ?? true;

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
                  onPressed:
                      _isApplyingToggle ? null : _rescheduleAllFromScreen,
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
                    enabled: _recurringRemindersEnabled,
                    isLoading: _isApplyingToggle,
                    onChanged: _onRecurringRemindersChanged,
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
                    isDisabled: _isApplyingToggle,
                    onTestTap: () => _sendTestNow(settings, isRTL),
                    onRescheduleTap: _rescheduleAllFromScreen,
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
  }
}
