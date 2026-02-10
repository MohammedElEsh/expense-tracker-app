import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ✅ Clean Architecture - Data Models Layer

enum AccountType {
  cash, // نقدي
  credit, // بطاقة ائتمان
  debit, // بطاقة خصم مباشر
  bank, // حساب بنكي
  digital, // محفظة رقمية
  gift, // بطاقة هدية
  investment, // استثمار
  savings, // توفير
}

extension AccountTypeExtension on AccountType {
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

  /// Get the API string value for this account type
  String get apiValue =>
      name; // Returns lowercase enum name (e.g., "cash", "credit")

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

  /// Parse AccountType from API string value
  static AccountType fromString(String? value) {
    if (value == null) return AccountType.cash;

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
}

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final double originalBalance; // المبلغ الأصلي المودع
  final String currency;
  final Color color;
  final IconData icon;
  final bool isActive;
  final bool includeInTotal; // هل يُحسب في الإجمالي العام
  final double? creditLimit; // حد الائتمان (للبطاقات الائتمانية)
  final String? description; // وصف إضافي
  final DateTime createdAt;
  final DateTime? updatedAt;

  Account({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    double? originalBalance,
    this.currency = 'SAR', // Use currency CODE (SAR, USD, EGP), not symbol
    Color? color,
    IconData? icon,
    this.isActive = true,
    this.includeInTotal = true,
    this.creditLimit,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       originalBalance = originalBalance ?? balance,
       color = color ?? type.defaultColor,
       icon = icon ?? type.icon,
       createdAt = createdAt ?? DateTime.now();

  /// Convert to Map for API requests (POST/PUT)
  /// Matches API expected format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.apiValue, // Send as string: "cash", "credit", etc.
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
      'isDefault': false, // Can be set separately
      'includeInTotal': includeInTotal,
      'creditLimit': creditLimit ?? 0,
      'description': description,
    };
  }

  /// Convert to Map for local storage (includes all fields)
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'type': type.apiValue,
      'balance': balance,
      'originalBalance': originalBalance,
      'currency': currency,
      'color': color.toARGB32(),
      'icon': icon.codePoint,
      'isActive': isActive,
      'includeInTotal': includeInTotal,
      'creditLimit': creditLimit ?? 0,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // Handle ISO 8601 date strings from API (e.g., "2025-12-15T23:18:46.976Z")
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('❌ Error parsing date string: $value');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Parse AccountType from API response
  /// Handles both string (from API) and int (legacy/local) formats
  static AccountType _parseAccountType(dynamic typeValue) {
    if (typeValue == null) return AccountType.cash;

    // Handle string type from API (e.g., "cash", "credit", "bank")
    if (typeValue is String) {
      return AccountTypeExtension.fromString(typeValue);
    }

    // Handle int type (legacy/local storage format)
    if (typeValue is int) {
      return typeValue < AccountType.values.length
          ? AccountType.values[typeValue]
          : AccountType.cash;
    }

    return AccountType.cash;
  }

  /// Helper function to get const IconData from codePoint based on AccountType
  /// If the codePoint matches the AccountType's default icon, returns that const icon
  /// Otherwise returns null (caller should use AccountType's default icon)
  static IconData? _getIconFromCodePoint(
    int codePoint,
    AccountType accountType,
  ) {
    final defaultIcon = accountType.icon;
    // If the stored codePoint matches the AccountType's icon, return the const icon
    if (defaultIcon.codePoint == codePoint) {
      return defaultIcon;
    }
    return null;
  }

  /// Create Account from API response Map
  /// Handles API format with _id, string type, ISO dates
  factory Account.fromMap(Map<String, dynamic> map) {
    try {
      // Handle both '_id' from API and 'id' from local storage
      final accountId =
          map['_id']?.toString() ?? map['id']?.toString() ?? const Uuid().v4();

      // Parse account type (handles both string and int)
      final accountType = _parseAccountType(map['type']);

      final balance =
          (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0;

      final originalBalance =
          (map['originalBalance'] is num)
              ? (map['originalBalance'] as num).toDouble()
              : balance;

      final creditLimit =
          (map['creditLimit'] is num)
              ? (map['creditLimit'] as num).toDouble()
              : null;

      return Account(
        id: accountId,
        name: map['name']?.toString() ?? 'حساب غير معروف',
        type: accountType,
        balance: balance,
        originalBalance: originalBalance,
        currency: map['currency']?.toString() ?? 'SAR',
        // Use default color if not provided or invalid
        color:
            map['color'] != null && map['color'] is int
                ? Color(map['color'] as int)
                : accountType.defaultColor,
        // Use default icon if not provided or invalid
        // Check if stored icon codePoint matches AccountType's default icon (for const safety)
        icon:
            (map['icon'] != null && map['icon'] is int)
                ? _getIconFromCodePoint(map['icon'] as int, accountType) ??
                    accountType.icon
                : accountType.icon,
        isActive: map['isActive'] ?? true,
        includeInTotal: map['includeInTotal'] ?? true,
        creditLimit: creditLimit,
        description: map['description']?.toString(),
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
      );
    } catch (e) {
      // في حالة الخطأ، أنشئ حساب افتراضي
      debugPrint('❌ خطأ في Account.fromMap: $e');
      debugPrint('❌ البيانات: $map');
      return Account(
        name: 'حساب افتراضي',
        type: AccountType.cash,
        balance: 0.0,
        description: 'تم إنشاؤه بسبب خطأ في البيانات',
      );
    }
  }

  // نسخة محدثة من الحساب
  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    double? originalBalance,
    String? currency,
    Color? color,
    IconData? icon,
    bool? isActive,
    bool? includeInTotal,
    double? creditLimit,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      originalBalance: originalBalance ?? this.originalBalance,
      currency: currency ?? this.currency,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      includeInTotal: includeInTotal ?? this.includeInTotal,
      creditLimit: creditLimit ?? this.creditLimit,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // حساب الرصيد المتاح (خاص بالبطاقات الائتمانية)
  double get availableBalance {
    if (type == AccountType.credit && creditLimit != null) {
      return creditLimit! + balance; // الرصيد سالب في البطاقات الائتمانية
    }
    return balance;
  }

  // حساب استخدام الائتمان (نسبة مئوية)
  double? get creditUsagePercentage {
    if (type == AccountType.credit && creditLimit != null && creditLimit! > 0) {
      return ((-balance) / creditLimit!) * 100;
    }
    return null;
  }

  // هل الحساب منخفض الرصيد؟
  bool get isLowBalance {
    if (type == AccountType.credit) {
      final usage = creditUsagePercentage;
      return usage != null && usage > 80; // أكثر من 80% من حد الائتمان
    }
    return balance < 100; // أقل من 100 للحسابات العادية
  }

  // حساب المبلغ المصروف (المبلغ الأصلي - الرصيد الحالي)
  double get spentAmount {
    return originalBalance - balance;
  }

  // نسبة المصروف من المبلغ الأصلي
  double get spentPercentage {
    if (originalBalance == 0) return 0.0;
    return (spentAmount / originalBalance) * 100;
  }

  // النص المناسب لعرض الرصيد
  String getBalanceText() {
    if (type == AccountType.credit) {
      if (balance == 0) {
        return 'لا توجد مستحقات';
      } else if (balance < 0) {
        return 'مستحق: ${(-balance).toStringAsFixed(2)} $currency';
      } else {
        return 'رصيد: ${balance.toStringAsFixed(2)} $currency';
      }
    }
    return '${balance.toStringAsFixed(2)} $currency';
  }

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
