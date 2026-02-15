// Add Expense - Account Dropdown Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/presentation/utils/account_type_display.dart';

class AccountDropdown extends StatelessWidget {
  final String? selectedAccountId;
  final List<AccountEntity> accounts;
  final bool isRTL;
  final Function(String?) onChanged;

  const AccountDropdown({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.isRTL,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
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

    // Remove duplicates
    final uniqueAccounts =
        accounts
            .fold<Map<String, AccountEntity>>({}, (map, account) {
              map[account.id] = account;
              return map;
            })
            .values
            .toList();

    return DropdownButtonFormField<String>(
      initialValue: selectedAccountId,
      decoration: InputDecoration(
        labelText: isRTL ? 'الحساب *' : 'Account *',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.account_balance_wallet),
        helperText: isRTL ? 'مطلوب' : 'Required',
      ),
      items:
          uniqueAccounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(account.type.icon, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      account.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return isRTL ? 'الحساب مطلوب' : 'Account is required';
        }
        return null;
      },
    );
  }
}
