// Accounts - Empty State Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/widgets/empty_state_widget.dart';
import 'package:expense_tracker/features/accounts/presentation/widgets/account_dialog.dart';

class AccountsEmptyState extends StatelessWidget {
  const AccountsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    return EmptyStateWidget(
      icon: Icons.account_balance_wallet,
      title: isRTL ? 'لا توجد حسابات' : 'No Accounts',
      subtitle:
          isRTL
              ? 'قم بإضافة حساب لبدء تتبع مصروفاتك. يمكنك إضافة المحفظة النقدية، البطاقات البنكية، أو المحافظ الرقمية.'
              : 'Add an account to start tracking your expenses. You can add cash wallet, bank cards, or digital wallets.',
      actionText: isRTL ? 'إضافة حساب' : 'Add Account',
      onAction: () {
        showDialog(
          context: context,
          builder: (context) => const AccountDialog(),
        );
      },
    );
  }
}
