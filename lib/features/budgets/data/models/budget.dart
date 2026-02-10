// =============================================================================
// BUDGET MODEL - Clean Architecture Data Layer
// =============================================================================

/// Budget model matching API response format
///
/// API Response Example:
/// {
///   "_id": "6946da3dd7d258df04f6eecb",
///   "month": 12,
///   "year": 2025,
///   "category": "طعام ومطاعم",
///   "appMode": "personal",
///   "userId": "694024fddcc5fbe3f92a71d6",
///   "limit": 3000,
///   "spent": 0,
///   "companyId": null,
///   "projectId": null,
///   "createdAt": "2025-12-20T17:17:49.608Z",
///   "updatedAt": "2025-12-20T17:17:49.608Z",
///   "id": "6946da3dd7d258df04f6eecb"
/// }
class Budget {
  final String id;
  final String category;
  final double limit;
  final double spent;
  final int year;
  final int month;
  final String? appMode;
  final String? userId;
  final String? companyId;
  final String? projectId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    this.spent = 0.0,
    required this.year,
    required this.month,
    this.appMode,
    this.userId,
    this.companyId,
    this.projectId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert Budget to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'spent': spent,
      'year': year,
      'month': month,
      'appMode': appMode,
      'userId': userId,
      'companyId': companyId,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Budget from API response JSON
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      // Handle both '_id' and 'id' fields from API
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      limit: _parseDouble(json['limit']),
      spent: _parseDouble(json['spent']),
      year: _parseInt(json['year']),
      month: _parseInt(json['month']),
      appMode: json['appMode']?.toString(),
      userId: json['userId']?.toString(),
      companyId: json['companyId']?.toString(),
      projectId: json['projectId']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
    );
  }

  /// Helper to parse double values safely
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper to parse int values safely
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Helper to parse DateTime safely
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Create a copy with modified fields
  Budget copyWith({
    String? id,
    String? category,
    double? limit,
    double? spent,
    int? year,
    int? month,
    String? appMode,
    String? userId,
    String? companyId,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      year: year ?? this.year,
      month: month ?? this.month,
      appMode: appMode ?? this.appMode,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===========================================================================
  // HELPER GETTERS
  // ===========================================================================

  /// Remaining amount (limit - spent)
  double get remaining => limit - spent;

  /// Usage percentage (0-100)
  double get usagePercentage => limit > 0 ? (spent / limit) * 100 : 0.0;

  /// Whether spending exceeds the budget limit
  bool get isOverBudget => spent > limit;

  /// Whether spending is near the limit (80%+) but not over
  bool get isNearLimit => usagePercentage >= 80 && !isOverBudget;

  /// Amount over budget (0 if not over)
  double get overAmount => isOverBudget ? spent - limit : 0.0;

  @override
  String toString() {
    return 'Budget(id: $id, category: $category, limit: $limit, spent: $spent, month: $month/$year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.category == category &&
        other.limit == limit &&
        other.spent == spent &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        category.hashCode ^
        limit.hashCode ^
        spent.hashCode ^
        year.hashCode ^
        month.hashCode;
  }
}
