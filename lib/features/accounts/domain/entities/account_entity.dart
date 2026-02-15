// =============================================================================
// ACCOUNT ENTITY - Clean Architecture Domain Layer (Pure Dart)
// =============================================================================

import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';

class AccountEntity {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final double originalBalance;
  final String currency;
  final bool isActive;
  final bool includeInTotal;
  final double? creditLimit;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    double? originalBalance,
    this.currency = 'SAR',
    this.isActive = true,
    this.includeInTotal = true,
    this.creditLimit,
    this.description,
    required this.createdAt,
    this.updatedAt,
  }) : originalBalance = originalBalance ?? balance;

  double get availableBalance {
    if (type == AccountType.credit && creditLimit != null) {
      return creditLimit! + balance;
    }
    return balance;
  }

  double? get creditUsagePercentage {
    if (type == AccountType.credit && creditLimit != null && creditLimit! > 0) {
      return ((-balance) / creditLimit!) * 100;
    }
    return null;
  }

  bool get isLowBalance {
    if (type == AccountType.credit) {
      final usage = creditUsagePercentage;
      return usage != null && usage > 80;
    }
    return balance < 100;
  }

  double get spentAmount => originalBalance - balance;

  double get spentPercentage {
    if (originalBalance == 0) return 0.0;
    return (spentAmount / originalBalance) * 100;
  }

  String getBalanceText() {
    if (type == AccountType.credit) {
      if (balance == 0) return 'لا توجد مستحقات';
      if (balance < 0) {
        return 'مستحق: ${(-balance).toStringAsFixed(2)} $currency';
      }
      return 'رصيد: ${balance.toStringAsFixed(2)} $currency';
    }
    return '${balance.toStringAsFixed(2)} $currency';
  }

  AccountEntity copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    double? originalBalance,
    String? currency,
    bool? isActive,
    bool? includeInTotal,
    double? creditLimit,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      originalBalance: originalBalance ?? this.originalBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      creditLimit: creditLimit ?? this.creditLimit,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AccountEntity(id: $id, name: $name, type: $type, balance: $balance)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
