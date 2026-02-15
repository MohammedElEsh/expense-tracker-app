// =============================================================================
// ACCOUNT MODEL - Data layer; extends domain entity, adds serialization.
// =============================================================================

import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_type.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.name,
    required super.type,
    super.balance = 0.0,
    super.originalBalance,
    super.currency = 'SAR',
    super.isActive = true,
    super.includeInTotal = true,
    super.creditLimit,
    super.description,
    required super.createdAt,
    super.updatedAt,
  });

  @override
  AccountModel copyWith({
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
    return AccountModel(
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

  /// For API requests (POST/PUT).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.apiValue,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'isDefault': false,
      'includeInTotal': includeInTotal,
      'creditLimit': creditLimit ?? 0,
      'description': description ?? '',
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'type': type.apiValue,
      'balance': balance,
      'originalBalance': originalBalance,
      'currency': currency,
      'isActive': isActive,
      'includeInTotal': includeInTotal,
      'creditLimit': creditLimit ?? 0,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    try {
      final accountId = map['_id']?.toString() ??
          map['id']?.toString() ??
          ''; // Caller/API should set id
      final accountType = accountTypeFromValue(map['type']);
      final balance =
          (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0;
      final originalBalance = (map['originalBalance'] is num)
          ? (map['originalBalance'] as num).toDouble()
          : balance;
      final creditLimit = (map['creditLimit'] is num)
          ? (map['creditLimit'] as num).toDouble()
          : null;
      final createdAt = _parseDateTime(map['createdAt']) ?? DateTime.now();
      final updatedAt = _parseDateTime(map['updatedAt']);

      return AccountModel(
        id: accountId.isEmpty ? _generateId() : accountId,
        name: map['name']?.toString() ?? 'حساب غير معروف',
        type: accountType,
        balance: balance,
        originalBalance: originalBalance,
        currency: map['currency']?.toString() ?? 'SAR',
        isActive: map['isActive'] ?? true,
        includeInTotal: map['includeInTotal'] ?? true,
        creditLimit: creditLimit,
        description: map['description']?.toString(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (_) {
      return AccountModel(
        id: _generateId(),
        name: 'حساب افتراضي',
        type: AccountType.cash,
        balance: 0.0,
        description: 'تم إنشاؤه بسبب خطأ في البيانات',
        createdAt: DateTime.now(),
      );
    }
  }

  static String _generateId() {
    // Simple id for fallback; API will replace with real id when synced.
    return 'local_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Build model from entity (e.g. when updating from presentation).
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      balance: entity.balance,
      originalBalance: entity.originalBalance,
      currency: entity.currency,
      isActive: entity.isActive,
      includeInTotal: entity.includeInTotal,
      creditLimit: entity.creditLimit,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
