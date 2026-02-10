/// وضع التطبيق - يحدد نوع الاستخدام
enum AppMode {
  /// الاستخدام الشخصي
  personal,

  /// الاستخدام التجاري للشركات الصغيرة
  business,
}

/// امتداد لـ AppMode لتوفير النصوص والأيقونات
extension AppModeExtension on AppMode {
  /// الاسم المعروض باللغة الإنجليزية
  String get englishName {
    switch (this) {
      case AppMode.personal:
        return 'Personal';
      case AppMode.business:
        return 'Business';
    }
  }

  /// الاسم المعروض باللغة العربية
  String get arabicName {
    switch (this) {
      case AppMode.personal:
        return 'شخصي';
      case AppMode.business:
        return 'تجاري';
    }
  }

  /// الحصول على الاسم المعروض حسب اللغة
  String getDisplayName(bool isRTL) {
    return isRTL ? arabicName : englishName;
  }

  /// الحصول على الاسم المعروض حسب اللغة (اسم مختصر)
  String displayName(bool isRTL) {
    return getDisplayName(isRTL);
  }

  /// الأيقونة المناسبة لكل وضع
  String get iconName {
    switch (this) {
      case AppMode.personal:
        return 'person';
      case AppMode.business:
        return 'business';
    }
  }

  /// الوصف باللغة الإنجليزية
  String get englishDescription {
    switch (this) {
      case AppMode.personal:
        return 'Track your personal expenses and manage your budget';
      case AppMode.business:
        return 'Manage company expenses, budgets, and financial reports';
    }
  }

  /// الوصف باللغة العربية
  String get arabicDescription {
    switch (this) {
      case AppMode.personal:
        return 'تتبع مصروفاتك الشخصية وإدارة ميزانيتك';
      case AppMode.business:
        return 'إدارة مصروفات الشركة والميزانيات والتقارير المالية';
    }
  }

  /// الحصول على الوصف حسب اللغة
  String getDescription(bool isRTL) {
    return isRTL ? arabicDescription : englishDescription;
  }

  /// اللون المناسب لكل وضع
  int get colorValue {
    switch (this) {
      case AppMode.personal:
        return 0xFF2196F3; // أزرق
      case AppMode.business:
        return 0xFF4CAF50; // أخضر
    }
  }
}
