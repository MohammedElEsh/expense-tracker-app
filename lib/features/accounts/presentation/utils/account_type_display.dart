// =============================================================================
// Account type display - Presentation only (icon, color, display names).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';

extension AccountTypeDisplay on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'نقدي';
      case AccountType.credit:
        return 'بطاقة ائتمان';
      case AccountType.debit:
        return 'بطاقة خصم';
      case AccountType.bank:
        return 'حساب بنكي';
      case AccountType.digital:
        return 'محفظة رقمية';
      case AccountType.gift:
        return 'بطاقة هدية';
      case AccountType.investment:
        return 'استثمار';
      case AccountType.savings:
        return 'توفير';
    }
  }

  String get englishName {
    switch (this) {
      case AccountType.cash:
        return 'Cash';
      case AccountType.credit:
        return 'Credit Card';
      case AccountType.debit:
        return 'Debit Card';
      case AccountType.bank:
        return 'Bank Account';
      case AccountType.digital:
        return 'Digital Wallet';
      case AccountType.gift:
        return 'Gift Card';
      case AccountType.investment:
        return 'Investment';
      case AccountType.savings:
        return 'Savings';
    }
  }

  IconData get icon {
    switch (this) {
      case AccountType.cash:
        return Icons.money;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.debit:
        return Icons.payment;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.digital:
        return Icons.account_balance_wallet;
      case AccountType.gift:
        return Icons.card_giftcard;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.savings:
        return Icons.savings;
    }
  }

  Color get defaultColor {
    switch (this) {
      case AccountType.cash:
        return Colors.green;
      case AccountType.credit:
        return Colors.blue;
      case AccountType.debit:
        return Colors.purple;
      case AccountType.bank:
        return Colors.indigo;
      case AccountType.digital:
        return Colors.orange;
      case AccountType.gift:
        return Colors.pink;
      case AccountType.investment:
        return Colors.teal;
      case AccountType.savings:
        return Colors.amber;
    }
  }
}
