// =============================================================================
// ACCOUNT TYPE - Clean Architecture Domain Layer (Pure Dart)
// =============================================================================

enum AccountType {
  cash,
  credit,
  debit,
  bank,
  digital,
  gift,
  investment,
  savings,
}

extension AccountTypeDomain on AccountType {
  String get apiValue => name;
  /// English label for search/display (domain-only; no Flutter).
  String get displayName {
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
}

AccountType accountTypeFromValue(dynamic value) {
  if (value == null) return AccountType.cash;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'cash':
        return AccountType.cash;
      case 'credit':
        return AccountType.credit;
      case 'debit':
        return AccountType.debit;
      case 'bank':
        return AccountType.bank;
      case 'digital':
        return AccountType.digital;
      case 'gift':
        return AccountType.gift;
      case 'investment':
        return AccountType.investment;
      case 'savings':
        return AccountType.savings;
      default:
        return AccountType.cash;
    }
  }
  if (value is int) {
    return value < AccountType.values.length
        ? AccountType.values[value]
        : AccountType.cash;
  }
  return AccountType.cash;
}
