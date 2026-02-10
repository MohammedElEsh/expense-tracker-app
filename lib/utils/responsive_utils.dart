import 'package:flutter/material.dart';

/// 📐 أداة للتعامل مع الشاشات المختلفة (Mobile, Tablet, Desktop)
class ResponsiveUtils {
  /// 🔍 التحقق من نوع الجهاز بناءً على العرض
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  /// 📱 الحصول على نوع الجهاز
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// 📏 الحصول على العرض الأقصى للمحتوى (للديسكتوب)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return MediaQuery.of(context).size.width;
  }

  /// 🔢 الحصول على عدد الأعمدة في Grid بناءً على نوع الجهاز
  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// 📐 الحصول على Padding بناءً على نوع الجهاز
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) return const EdgeInsets.all(32);
    if (isTablet(context)) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  /// 🔤 الحصول على حجم الخط بناءً على نوع الجهاز
  static double getTitleFontSize(BuildContext context) {
    if (isDesktop(context)) return 28;
    if (isTablet(context)) return 24;
    return 20;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 15;
    return 14;
  }

  static double getSubtitleFontSize(BuildContext context) {
    if (isDesktop(context)) return 14;
    if (isTablet(context)) return 13;
    return 12;
  }

  /// 🎨 الحصول على حجم الأيقونة بناءً على نوع الجهاز
  static double getIconSize(BuildContext context) {
    if (isDesktop(context)) return 28;
    if (isTablet(context)) return 26;
    return 24;
  }

  /// 📊 الحصول على ارتفاع العناصر بناءً على نوع الجهاز
  static double getListTileHeight(BuildContext context) {
    if (isDesktop(context)) return 80;
    if (isTablet(context)) return 72;
    return 68;
  }

  /// 🪟 الحصول على عرض Dialog بناءً على نوع الجهاز
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return screenWidth * 0.7;
    return screenWidth * 0.9;
  }

  /// 📏 الحصول على ارتفاع Dialog بناءً على نوع الجهاز
  static double? getDialogMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (isDesktop(context)) return screenHeight * 0.8;
    if (isTablet(context)) return screenHeight * 0.85;
    return screenHeight * 0.9;
  }

  /// 🎯 الحصول على قيمة مخصصة بناءً على نوع الجهاز
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// 📱 Widget مخصص يغير التخطيط بناءً على نوع الجهاز
  static Widget adaptive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    required BuildContext context,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// 🖥️ تخطيط Sidebar للديسكتوب (Layout with navigation rail)
  static Widget desktopLayout({
    required Widget navigationRail,
    required Widget content,
    required BuildContext context,
  }) {
    return Row(
      children: [
        navigationRail,
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: getMaxContentWidth(context),
              ),
              child: content,
            ),
          ),
        ),
      ],
    );
  }

  /// 📱 تخطيط Mobile (Layout with bottom navigation)
  static Widget mobileLayout({
    required Widget content,
    required Widget? bottomNavigationBar,
  }) {
    return Scaffold(body: content, bottomNavigationBar: bottomNavigationBar);
  }

  /// 🎨 الحصول على Border Radius بناءً على نوع الجهاز
  static double getBorderRadius(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 14;
    return 12;
  }

  /// 📏 الحصول على Card Elevation بناءً على نوع الجهاز
  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// 🔢 الحصول على Spacing بناءً على نوع الجهاز
  static double getSpacing(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 16;
  }

  static double getSmallSpacing(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 14;
    return 12;
  }

  static double getTinySpacing(BuildContext context) {
    if (isDesktop(context)) return 12;
    if (isTablet(context)) return 10;
    return 8;
  }

  /// 🪟 الحصول على أبعاد Dialog/Modal Sheet بناءً على Platform
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    if (isDesktop(context)) {
      // Dialog للديسكتوب
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(getBorderRadius(context)),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: getDialogWidth(context),
                  maxHeight: getDialogMaxHeight(context) ?? double.infinity,
                ),
                child: builder(context),
              ),
            ),
      );
    } else {
      // Bottom Sheet للموبايل والتابلت
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: barrierDismissible,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              constraints: BoxConstraints(
                maxHeight: getDialogMaxHeight(context) ?? double.infinity,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(getBorderRadius(context)),
                ),
              ),
              child: builder(context),
            ),
      );
    }
  }
}

/// 🎯 Enum لأنواع الأجهزة
enum DeviceType { mobile, tablet, desktop }

/// 🎨 Extension على BuildContext للوصول السريع
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);

  double get titleFontSize => ResponsiveUtils.getTitleFontSize(this);
  double get bodyFontSize => ResponsiveUtils.getBodyFontSize(this);
  double get subtitleFontSize => ResponsiveUtils.getSubtitleFontSize(this);

  double get iconSize => ResponsiveUtils.getIconSize(this);
  double get spacing => ResponsiveUtils.getSpacing(this);
  double get smallSpacing => ResponsiveUtils.getSmallSpacing(this);
  double get tinySpacing => ResponsiveUtils.getTinySpacing(this);

  EdgeInsets get screenPadding => ResponsiveUtils.getScreenPadding(this);
  double get borderRadius => ResponsiveUtils.getBorderRadius(this);
  double get cardElevation => ResponsiveUtils.getCardElevation(this);
}
