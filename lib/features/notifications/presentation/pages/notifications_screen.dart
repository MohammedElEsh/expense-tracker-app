// Notifications Feature - Recurring expense reminders toggle + Upcoming reminders list (Option 2)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../recurring_expenses/presentation/bloc/recurring_expense_state.dart';

/// Keep in sync with RecurringExpenseNotificationService defaults.
/// (Later: read these from settings instead.)
const int _defaultReminderHour = 9;
const int _defaultReminderMinute = 0;

/// Upcoming window for in-app reminders list.
const int _defaultUpcomingDays = 30;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool? _recurringRemindersEnabled;
  bool _isApplyingToggle = false;
  final bool _showDebug = false;

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

  Future<void> _onRecurringRemindersChanged(bool value) async {
    if (_isApplyingToggle) return;

    setState(() => _isApplyingToggle = true);

    try {
      await serviceLocator.prefHelper.setRecurringExpenseRemindersEnabled(
        value,
      );
      if (mounted) setState(() => _recurringRemindersEnabled = value);

      // If enabling, request permissions first (Android 13+ / iOS)
      if (value) {
        await _requestPermissionsIfNeeded();
      }

      // Keep schedules in sync with state
      final bloc = context.read<RecurringExpenseBloc>();
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
    final bloc = context.read<RecurringExpenseBloc>();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

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
                  _buildRecurringRemindersCard(settings, isRTL),
                  const SizedBox(height: 14),
                  _buildQuickActions(settings, isRTL),
                  const SizedBox(height: 18),
                  _buildUpcomingSection(settings, isRTL),
                  const SizedBox(height: 18),
                  _buildComingSoonSection(settings, isRTL),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecurringRemindersCard(SettingsState settings, bool isRTL) {
    final enabled = _recurringRemindersEnabled ?? true;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(
        alpha: settings.isDarkMode ? 0.25 : 0.08,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SwitchListTile(
          value: enabled,
          onChanged:
              (_recurringRemindersEnabled == null || _isApplyingToggle)
                  ? null
                  : _onRecurringRemindersChanged,
          title: Text(
            isRTL ? 'تذكير بالمصروفات المتكررة' : 'Recurring expense reminders',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: settings.primaryTextColor,
            ),
          ),
          subtitle: Text(
            isRTL
                ? 'سيستم إشعارات على موعد المصروف (مثلاً 9:00 ص)'
                : 'System reminders at due time (e.g. 9:00 AM)',
            style: TextStyle(fontSize: 13, color: settings.secondaryTextColor),
          ),
          secondary: Icon(Icons.repeat_rounded, color: settings.primaryColor),
          activeColor: settings.primaryColor,
        ),
      ),
    );
  }

  Widget _buildQuickActions(SettingsState settings, bool isRTL) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.notifications_rounded,
            title: isRTL ? 'اختبار' : 'Test',
            subtitle: isRTL ? 'إشعار فوري' : 'Send now',
            color: settings.primaryColor,
            isDisabled: _isApplyingToggle,
            onTap: () => _sendTestNow(settings, isRTL),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.schedule_rounded,
            title: isRTL ? 'إعادة جدولة' : 'Reschedule',
            subtitle: isRTL ? 'كل التذكيرات' : 'All reminders',
            color: settings.primaryColor,
            isDisabled: _isApplyingToggle,
            onTap: _rescheduleAllFromScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(SettingsState settings, bool isRTL) {
    return BlocBuilder<RecurringExpenseBloc, RecurringExpenseState>(
      builder: (context, state) {
        final enabled = _recurringRemindersEnabled ?? true;

        final expenses =
            state.hasLoaded ? state.allRecurringExpenses : <RecurringExpense>[];
        final items = _buildUpcomingItems(expenses);

        return Column(
          crossAxisAlignment:
              isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isRTL ? 'التذكيرات القادمة' : 'Upcoming reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: settings.primaryTextColor,
                      ),
                    ),
                  ),
                  Text(
                    isRTL
                        ? '$_defaultUpcomingDays يوم'
                        : '$_defaultUpcomingDays days',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: settings.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (!enabled)
              _InfoBanner(
                icon: Icons.notifications_off_outlined,
                text:
                    isRTL
                        ? 'التذكيرات مقفولة. القائمة دي للعرض فقط.'
                        : 'Reminders are disabled. This list is display-only.',
                settings: settings,
              ),
            if (items.isEmpty)
              _EmptyStateCard(
                title: isRTL ? 'مفيش تذكيرات قريبة' : 'No upcoming reminders',
                subtitle:
                    isRTL
                        ? 'فعّل مصروفات متكررة أو زوّد الفترة.'
                        : 'Enable recurring expenses or increase the window.',
                settings: settings,
              )
            else
              Card(
                elevation: 1.5,
                shadowColor: Colors.black.withValues(
                  alpha: settings.isDarkMode ? 0.22 : 0.06,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder:
                      (_, _) => Divider(
                        height: 1,
                        color: settings.primaryColor.withValues(alpha: 0.12),
                      ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: settings.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.isToday
                              ? Icons.today_rounded
                              : item.isTomorrow
                              ? Icons.event_available_rounded
                              : Icons.schedule_rounded,
                          color: settings.primaryColor,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: settings.primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        '${item.relativeLabel} • ${item.dateLabel}',
                        style: TextStyle(
                          fontSize: 12.8,
                          color: settings.secondaryTextColor,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.amountLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: settings.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            enabled
                                ? (isRTL ? 'مُفعّل' : 'Enabled')
                                : (isRTL ? 'متوقف' : 'Off'),
                            style: TextStyle(
                              fontSize: 11.8,
                              fontWeight: FontWeight.w700,
                              color:
                                  enabled
                                      ? settings.primaryColor
                                      : settings.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // If you have a details screen route, navigate here.
                        // Example:
                        // Navigator.pushNamed(context, Routes.recurringExpenseDetails, arguments: item.expenseId);
                        debugPrint(
                          'Upcoming reminder tapped: ${item.expenseId}',
                        );
                      },
                    );
                  },
                ),
              ),

            if (_showDebug) ...[
              const SizedBox(height: 10),
              _DebugCard(settings: settings),
            ],
          ],
        );
      },
    );
  }

  List<_UpcomingItem> _buildUpcomingItems(List<RecurringExpense> expenses) {
    final now = tz.TZDateTime.now(tz.local);
    final end = now.add(const Duration(days: _defaultUpcomingDays));

    final List<_UpcomingItem> items = [];

    for (final e in expenses) {
      if (!e.isActive || e.id.isEmpty) continue;

      final next = _nextReminderDate(e, now);
      if (next.isBefore(now) || next.isAfter(end)) continue;

      final diffDays = next.difference(now).inDays;
      final isToday = diffDays == 0 && next.day == now.day;
      final isTomorrow = diffDays <= 1 && !isToday;

      items.add(
        _UpcomingItem(
          expenseId: e.id,
          title: 'Recurring: ${e.category}',
          amountLabel: e.amount.toStringAsFixed(2),
          dateLabel:
              '${_two(next.day)}/${_two(next.month)}/${next.year} • ${_two(next.hour)}:${_two(next.minute)}',
          relativeLabel:
              isToday
                  ? 'Today'
                  : isTomorrow
                  ? 'Tomorrow'
                  : 'In $diffDays days',
          isToday: isToday,
          isTomorrow: isTomorrow,
          date: next,
        ),
      );
    }

    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  tz.TZDateTime _nextReminderDate(RecurringExpense expense, tz.TZDateTime now) {
    final base = expense.nextDue ?? expense.calculateNextDue();
    var candidate = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day,
      _defaultReminderHour,
      _defaultReminderMinute,
    );

    if (!candidate.isBefore(now)) return candidate;

    // If candidate is in the past, compute next occurrence based on recurrenceType.
    switch (expense.recurrenceType) {
      case RecurrenceType.daily:
        while (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;

      case RecurrenceType.weekly:
        // Move forward 7 days until in the future
        while (candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 7));
        }
        return candidate;

      case RecurrenceType.monthly:
        // Move month by month; clamp day to last day-of-month if needed
        while (candidate.isBefore(now)) {
          final nextMonth = _addMonths(candidate, 1);
          final day = candidate.day;
          final clampedDay = _clampDayOfMonth(
            nextMonth.year,
            nextMonth.month,
            day,
          );
          candidate = tz.TZDateTime(
            tz.local,
            nextMonth.year,
            nextMonth.month,
            clampedDay,
            _defaultReminderHour,
            _defaultReminderMinute,
          );
        }
        return candidate;

      case RecurrenceType.yearly:
        while (candidate.isBefore(now)) {
          candidate = tz.TZDateTime(
            tz.local,
            candidate.year + 1,
            candidate.month,
            candidate.day,
            _defaultReminderHour,
            _defaultReminderMinute,
          );
        }
        return candidate;
    }
  }

  tz.TZDateTime _addMonths(tz.TZDateTime date, int monthsToAdd) {
    final y = date.year + ((date.month - 1 + monthsToAdd) ~/ 12);
    final m = ((date.month - 1 + monthsToAdd) % 12) + 1;
    return tz.TZDateTime(tz.local, y, m, 1, date.hour, date.minute);
  }

  int _clampDayOfMonth(int year, int month, int day) {
    final last = DateTime(year, month + 1, 0).day;
    return day <= last ? day : last;
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  Widget _buildComingSoonSection(SettingsState settings, bool isRTL) {
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            isRTL ? 'قريباً' : 'Coming soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
        ),
        _buildFeatureItem(
          Icons.warning_amber_outlined,
          isRTL
              ? 'تنبيهات الميزانية (80% و 100%)'
              : 'Budget alerts (80% & 100%)',
          settings,
        ),
        _buildFeatureItem(
          Icons.folder_open,
          isRTL ? 'تنبيهات مواعيد المشاريع' : 'Project deadline alerts',
          settings,
        ),
        _buildFeatureItem(
          Icons.check_circle_outline,
          isRTL
              ? 'إشعارات الموافقات (تجاري)'
              : 'Approval notifications (Business)',
          settings,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, SettingsState settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: settings.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: settings.primaryTextColor.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------- Small UI helpers ---------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.isDisabled,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.6 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.10),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withValues(alpha: 0.16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.settings,
  });

  final IconData icon;
  final String text;
  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: settings.primaryColor.withValues(alpha: 0.10),
        border: Border.all(
          color: settings.primaryColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: settings.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: settings.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.settings,
  });

  final String title;
  final String subtitle;
  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(
        alpha: settings.isDarkMode ? 0.22 : 0.06,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: settings.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.inbox_outlined, color: settings.primaryColor),
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
                      color: settings.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.8,
                      color: settings.secondaryTextColor,
                    ),
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

class _DebugCard extends StatelessWidget {
  const _DebugCard({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shadowColor: Colors.black.withValues(
        alpha: settings.isDarkMode ? 0.22 : 0.06,
      ),
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
                color: settings.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Uses recurring expenses data to render upcoming reminders (next $_defaultUpcomingDays days)\n'
              '• Not a notification history feed\n'
              '• System notifications are scheduled separately via flutter_local_notifications',
              style: TextStyle(
                fontSize: 12.5,
                color: settings.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingItem {
  _UpcomingItem({
    required this.expenseId,
    required this.title,
    required this.amountLabel,
    required this.dateLabel,
    required this.relativeLabel,
    required this.isToday,
    required this.isTomorrow,
    required this.date,
  });

  final String expenseId;
  final String title;
  final String amountLabel;
  final String dateLabel;
  final String relativeLabel;
  final bool isToday;
  final bool isTomorrow;
  final tz.TZDateTime date;
}
