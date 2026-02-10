import 'package:expense_tracker/features/notifications/presentation/widgets/notification_debug_card.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_empty_state_card.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/notification_info_banner.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminder_item.dart';
import 'package:expense_tracker/features/notifications/presentation/widgets/upcoming_reminder_tile.dart';
import 'package:expense_tracker/features/recurring_expenses/data/models/recurring_expense.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_cubit.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/cubit/recurring_expense_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Displays the "Upcoming reminders" header, info banner, and list of
/// upcoming recurring-expense reminders.
class UpcomingRemindersSection extends StatelessWidget {
  const UpcomingRemindersSection({
    super.key,
    required this.remindersEnabled,
    required this.showDebug,
    required this.isRTL,
    required this.primaryColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.isDarkMode,
  });

  final bool remindersEnabled;
  final bool showDebug;
  final bool isRTL;
  final Color primaryColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringExpenseCubit, RecurringExpenseState>(
      builder: (context, state) {
        final expenses =
            state.hasLoaded ? state.allRecurringExpenses : <RecurringExpense>[];
        final items = UpcomingItemsBuilder.build(expenses);

        return Column(
          crossAxisAlignment:
              isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ---- Header ----
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
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  Text(
                    isRTL
                        ? '$defaultUpcomingDays يوم'
                        : '$defaultUpcomingDays days',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ---- Disabled banner ----
            if (!remindersEnabled)
              NotificationInfoBanner(
                icon: Icons.notifications_off_outlined,
                text:
                    isRTL
                        ? 'التذكيرات مقفولة. القائمة دي للعرض فقط.'
                        : 'Reminders are disabled. This list is display-only.',
                primaryColor: primaryColor,
                primaryTextColor: primaryTextColor,
              ),

            // ---- Empty state or list ----
            if (items.isEmpty)
              NotificationEmptyStateCard(
                title: isRTL ? 'مفيش تذكيرات قريبة' : 'No upcoming reminders',
                subtitle:
                    isRTL
                        ? 'فعّل مصروفات متكررة أو زوّد الفترة.'
                        : 'Enable recurring expenses or increase the window.',
                primaryColor: primaryColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDarkMode: isDarkMode,
              )
            else
              Card(
                elevation: 1.5,
                shadowColor: Colors.black.withValues(
                  alpha: isDarkMode ? 0.22 : 0.06,
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
                        color: primaryColor.withValues(alpha: 0.12),
                      ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return UpcomingReminderTile(
                      item: item,
                      isEnabled: remindersEnabled,
                      isRTL: isRTL,
                      primaryColor: primaryColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () {
                        debugPrint(
                          'Upcoming reminder tapped: ${item.expenseId}',
                        );
                      },
                    );
                  },
                ),
              ),

            // ---- Debug card ----
            if (showDebug) ...[
              const SizedBox(height: 10),
              NotificationDebugCard(
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDarkMode: isDarkMode,
              ),
            ],
          ],
        );
      },
    );
  }
}
