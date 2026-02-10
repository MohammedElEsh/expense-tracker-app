/// Settings model matching API response structure
class SettingsModel {
  final String id;
  final String userId;
  final String currency;
  final String language;
  final String theme; // 'light' or 'dark'
  final bool notifications;
  final String? companyName;
  final String? companyLogo;
  final String? invoicePrefix;
  final String? dateFormat;
  final String? timeFormat;
  final String? fiscalYearStart;
  final int? budgetWarningThreshold;
  final bool? overBudgetAlert;
  final bool? lowBalanceAlert;
  final int? lowBalanceThreshold;
  final bool? autoProcessRecurring;
  final String? defaultReportPeriod;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SettingsModel({
    required this.id,
    required this.userId,
    this.currency = 'SAR',
    this.language = 'en',
    this.theme = 'light',
    this.notifications = false,
    this.companyName,
    this.companyLogo,
    this.invoicePrefix,
    this.dateFormat,
    this.timeFormat,
    this.fiscalYearStart,
    this.budgetWarningThreshold,
    this.overBudgetAlert,
    this.lowBalanceAlert,
    this.lowBalanceThreshold,
    this.autoProcessRecurring,
    this.defaultReportPeriod,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from API JSON response
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      currency: map['currency']?.toString() ?? 'SAR',
      language: map['language']?.toString() ?? 'en',
      theme: map['theme']?.toString() ?? 'light',
      notifications: map['notifications'] == true || map['notifications'] == 'true',
      companyName: map['companyName']?.toString(),
      companyLogo: map['companyLogo']?.toString(),
      invoicePrefix: map['invoicePrefix']?.toString(),
      dateFormat: map['dateFormat']?.toString(),
      timeFormat: map['timeFormat']?.toString(),
      fiscalYearStart: map['fiscalYearStart']?.toString(),
      budgetWarningThreshold: map['budgetWarningThreshold'] is int
          ? map['budgetWarningThreshold'] as int
          : map['budgetWarningThreshold'] != null
              ? int.tryParse(map['budgetWarningThreshold'].toString())
              : null,
      overBudgetAlert: map['overBudgetAlert'] == true || map['overBudgetAlert'] == 'true',
      lowBalanceAlert: map['lowBalanceAlert'] == true || map['lowBalanceAlert'] == 'true',
      lowBalanceThreshold: map['lowBalanceThreshold'] is int
          ? map['lowBalanceThreshold'] as int
          : map['lowBalanceThreshold'] != null
              ? int.tryParse(map['lowBalanceThreshold'].toString())
              : null,
      autoProcessRecurring: map['autoProcessRecurring'] == true || map['autoProcessRecurring'] == 'true',
      defaultReportPeriod: map['defaultReportPeriod']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }

  /// Convert to API request JSON
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'currency': currency,
      'language': language,
      'theme': theme,
      'notifications': notifications,
    };

    if (companyName != null) map['companyName'] = companyName;
    if (companyLogo != null) map['companyLogo'] = companyLogo;
    if (invoicePrefix != null) map['invoicePrefix'] = invoicePrefix;
    if (dateFormat != null) map['dateFormat'] = dateFormat;
    if (timeFormat != null) map['timeFormat'] = timeFormat;
    if (fiscalYearStart != null) map['fiscalYearStart'] = fiscalYearStart;
    if (budgetWarningThreshold != null) map['budgetWarningThreshold'] = budgetWarningThreshold;
    if (overBudgetAlert != null) map['overBudgetAlert'] = overBudgetAlert;
    if (lowBalanceAlert != null) map['lowBalanceAlert'] = lowBalanceAlert;
    if (lowBalanceThreshold != null) map['lowBalanceThreshold'] = lowBalanceThreshold;
    if (autoProcessRecurring != null) map['autoProcessRecurring'] = autoProcessRecurring;
    if (defaultReportPeriod != null) map['defaultReportPeriod'] = defaultReportPeriod;

    return map;
  }

  /// Create a copy with updated fields
  SettingsModel copyWith({
    String? currency,
    String? language,
    String? theme,
    bool? notifications,
    String? companyName,
    String? companyLogo,
    String? invoicePrefix,
    String? dateFormat,
    String? timeFormat,
    String? fiscalYearStart,
    int? budgetWarningThreshold,
    bool? overBudgetAlert,
    bool? lowBalanceAlert,
    int? lowBalanceThreshold,
    bool? autoProcessRecurring,
    String? defaultReportPeriod,
  }) {
    return SettingsModel(
      id: id,
      userId: userId,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      budgetWarningThreshold: budgetWarningThreshold ?? this.budgetWarningThreshold,
      overBudgetAlert: overBudgetAlert ?? this.overBudgetAlert,
      lowBalanceAlert: lowBalanceAlert ?? this.lowBalanceAlert,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      autoProcessRecurring: autoProcessRecurring ?? this.autoProcessRecurring,
      defaultReportPeriod: defaultReportPeriod ?? this.defaultReportPeriod,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Helper: Check if theme is dark
  bool get isDarkMode => theme == 'dark';

  @override
  String toString() {
    return 'SettingsModel(id: $id, currency: $currency, language: $language, theme: $theme, notifications: $notifications)';
  }
}

