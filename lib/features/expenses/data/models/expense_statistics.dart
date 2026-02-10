import 'package:flutter/foundation.dart';

// =============================================================================
// EXPENSE STATISTICS MODELS - API Response Models
// =============================================================================

/// Expense statistics model
class ExpenseStatistics {
  final double totalAmount;
  final int totalCount;
  final double averageAmount;
  final Map<String, double> categoryTotals;
  final Map<String, int> categoryCounts;

  ExpenseStatistics({
    required this.totalAmount,
    required this.totalCount,
    required this.averageAmount,
    required this.categoryTotals,
    required this.categoryCounts,
  });

  factory ExpenseStatistics.fromJson(Map<String, dynamic> json) {
    return ExpenseStatistics(
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? json['count'] ?? 0,
      averageAmount:
          (json['averageAmount'] ?? json['average'] ?? 0.0).toDouble(),
      categoryTotals: Map<String, double>.from(
        json['categoryTotals'] ?? json['categories'] ?? {},
      ),
      categoryCounts: Map<String, int>.from(json['categoryCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'averageAmount': averageAmount,
      'categoryTotals': categoryTotals,
      'categoryCounts': categoryCounts,
    };
  }
}

/// Monthly summary model
class MonthlySummary {
  final int year;
  final int month;
  final double totalAmount;
  final int totalCount;
  final Map<String, double> categoryTotals;

  MonthlySummary({
    required this.year,
    required this.month,
    required this.totalAmount,
    required this.totalCount,
    required this.categoryTotals,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? json['count'] ?? 0,
      categoryTotals: Map<String, double>.from(
        json['categoryTotals'] ?? json['categories'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'categoryTotals': categoryTotals,
    };
  }

  DateTime get date => DateTime(year, month);
}

/// Category summary model
class CategorySummary {
  final String category;
  final double totalAmount;
  final int totalCount;
  final double percentage;

  CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.totalCount,
    required this.percentage,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'] ?? '',
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'percentage': percentage,
    };
  }
}

/// Account summary model
class AccountSummary {
  final String accountId;
  final String accountName;
  final double totalAmount;
  final int totalCount;
  final String currency;

  AccountSummary({
    required this.accountId,
    required this.accountName,
    required this.totalAmount,
    required this.totalCount,
    required this.currency,
  });

  factory AccountSummary.fromJson(Map<String, dynamic> json) {
    // Handle nested account object
    final accountData = json['account'] ?? json['accountId'] ?? {};
    final accountId =
        accountData is String
            ? accountData
            : (accountData['_id'] ?? accountData['id'] ?? '');

    return AccountSummary(
      accountId: accountId,
      accountName:
          accountData is Map
              ? (accountData['name'] ?? '')
              : (json['accountName'] ?? ''),
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? json['count'] ?? 0,
      currency:
          accountData is Map
              ? (accountData['currency'] ?? 'EGP')
              : (json['currency'] ?? 'EGP'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'currency': currency,
    };
  }
}

/// Timeline entry model
class TimelineEntry {
  final DateTime date;
  final double totalAmount;
  final int totalCount;
  final List<String> expenseIds;

  TimelineEntry({
    required this.date,
    required this.totalAmount,
    required this.totalCount,
    required this.expenseIds,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) {
    return TimelineEntry(
      date: _parseDateTime(json['date']),
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0.0).toDouble(),
      totalCount: json['totalCount'] ?? json['count'] ?? 0,
      expenseIds: List<String>.from(json['expenseIds'] ?? []),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('❌ Error parsing date string: $value');
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'expenseIds': expenseIds,
    };
  }
}
