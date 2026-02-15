import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/accounts/presentation/utils/account_type_display.dart';

class OcrAccountSelector extends StatelessWidget {
  const OcrAccountSelector({
    super.key,
    required this.settings,
    required this.isRTL,
    required this.selectedAccountId,
    required this.onAccountChanged,
  });

  final SettingsState settings;
  final bool isRTL;
  final String? selectedAccountId;
  final ValueChanged<String> onAccountChanged;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, accountState) {
        final accounts = accountState.activeAccounts;

        if (accounts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRTL
                        ? 'لا توجد حسابات. يرجى إضافة حساب أولاً.'
                        : 'No accounts available. Please add an account first.',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: settings.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selectedAccountId == null
                      ? Colors.red.withValues(alpha: 0.5)
                      : settings.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedAccountId,
            decoration: InputDecoration(
              labelText: isRTL ? 'الحساب *' : 'Account *',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: settings.primaryColor,
              ),
              helperText: isRTL ? 'مطلوب' : 'Required',
            ),
            items:
                accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(account.type.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                onAccountChanged(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isRTL ? 'الحساب مطلوب' : 'Account is required';
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
