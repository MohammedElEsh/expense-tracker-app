/// وضع التطبيق - يحدد نوع الاستخدام
/// Core domain: app-wide entity, pure Dart, framework-independent, immutable.
enum AppMode {
  /// الاستخدام الشخصي
  personal,

  /// الاستخدام التجاري للشركات الصغيرة
  business,
}

/// Helper methods for display names and descriptions (pure Dart, no Flutter).
extension AppModeExtension on AppMode {
  String get englishName {
    switch (this) {
      case AppMode.personal:
        return 'Personal';
      case AppMode.business:
        return 'Business';
    }
  }

  String get arabicName {
    switch (this) {
      case AppMode.personal:
        return 'شخصي';
      case AppMode.business:
        return 'تجاري';
    }
  }

  String getDisplayName(bool isRTL) => isRTL ? arabicName : englishName;

  String displayName(bool isRTL) => getDisplayName(isRTL);

  String get iconName {
    switch (this) {
      case AppMode.personal:
        return 'person';
      case AppMode.business:
        return 'business';
    }
  }

  String get englishDescription {
    switch (this) {
      case AppMode.personal:
        return 'Track your personal expenses and manage your budget';
      case AppMode.business:
        return 'Manage company expenses, budgets, and financial reports';
    }
  }

  String get arabicDescription {
    switch (this) {
      case AppMode.personal:
        return 'تتبع مصروفاتك الشخصية وإدارة ميزانيتك';
      case AppMode.business:
        return 'إدارة مصروفات الشركة والميزانيات والتقارير المالية';
    }
  }

  String getDescription(bool isRTL) => isRTL ? arabicDescription : englishDescription;

  int get colorValue {
    switch (this) {
      case AppMode.personal:
        return 0xFF2196F3;
      case AppMode.business:
        return 0xFF4CAF50;
    }
  }
}
