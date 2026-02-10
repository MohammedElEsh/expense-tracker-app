import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import '../widgets/animated_page_route.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';

class SimpleAddFAB extends StatelessWidget {
  final DateTime selectedDate;

  const SimpleAddFAB({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          backgroundColor: settings.primaryColor,
          foregroundColor: settings.isDarkMode ? Colors.black : Colors.white,
          elevation: 8,
          heroTag: "add_expense_fab",
          child: const Icon(Icons.add, size: 28),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final settings = context.read<SettingsBloc>().state;
    final isRTL = settings.language == 'ar';

    // فحص وجود حسابات أولاً
    final accountState = context.read<AccountBloc>().state;

    if (accountState.accounts.isEmpty) {
      // عرض Dialog تحذيري
      final result = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRTL ? 'لا توجد حسابات بنكية!' : 'No Bank Accounts!',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
              content: Text(
                isRTL
                    ? 'يجب إضافة حساب بنكي واحد على الأقل قبل إضافة المصروفات.\n\nهل تريد إضافة حساب الآن؟'
                    : 'You must add at least one bank account before adding expenses.\n\nDo you want to add an account now?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(isRTL ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.add),
                  label: Text(isRTL ? 'إضافة حساب' : 'Add Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
      );

      // إذا وافق المستخدم، انتقل لشاشة الحسابات
      if (result == true && context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const AccountsScreen()));
      }
      return;
    }

    // إذا يوجد حسابات، افتح Dialog الإضافة
    Navigator.of(context).pushWithAnimation(
      AddExpenseDialog(selectedDate: selectedDate),
      animationType: AnimationType.slideUp,
    );
  }
}
