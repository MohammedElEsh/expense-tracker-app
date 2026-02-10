// Home Feature - Presentation Layer - Home AppBar Widget
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isRTL;
  final bool isDesktop;
  final bool isTablet;
  final AppMode appMode;
  final User? currentUser;
  final VoidCallback onLogout;
  final VoidCallback onSearch;

  const HomeAppBar({
    super.key,
    required this.isRTL,
    required this.isDesktop,
    required this.isTablet,
    required this.appMode,
    this.currentUser,
    required this.onLogout,
    required this.onSearch,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(isDesktop ? 72 : (isTablet ? 68 : kToolbarHeight));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final personalModeColor =
        isDark ? AppColors.darkSecondary : AppColors.secondary;
    final businessModeColor =
        isDark ? AppColors.darkPrimary : AppColors.primary;

    return Directionality(
      textDirection: ui.TextDirection.ltr, // ⭐ فرض LTR دائماً للـ AppBar
      child: AppBar(
        automaticallyImplyLeading: true, // ⭐ تفعيل الـ drawer icon
        leading:
            isDesktop
                ? null
                : null, // Let Flutter handle drawer icon automatically
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // العنوان على اليسار - مرن
            Flexible(
              child: Text(
                isRTL ? 'متتبع المصروفات' : 'Expense Tracker',
                style: (isDesktop
                        ? AppTypography.headlineLarge
                        : (isTablet
                            ? AppTypography.headlineMedium
                            : AppTypography.titleMedium))
                    .copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isDesktop ? AppSpacing.md : AppSpacing.xs),
            // User info على اليمين - مضغوط
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Mode Icon
                Container(
                  width: isDesktop ? AppSpacing.iconXl : AppSpacing.iconLg,
                  height: isDesktop ? AppSpacing.iconXl : AppSpacing.iconLg,
                  decoration: BoxDecoration(
                    color:
                        appMode == AppMode.personal
                            ? personalModeColor.withValues(alpha: 0.2)
                            : businessModeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    appMode == AppMode.personal ? Icons.person : Icons.business,
                    color:
                        appMode == AppMode.personal
                            ? personalModeColor
                            : businessModeColor,
                    size: isDesktop ? AppSpacing.iconSm : AppSpacing.iconXs,
                  ),
                ),
                SizedBox(width: isDesktop ? AppSpacing.sm : AppSpacing.xs),
                // App Mode and User Info
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appMode == AppMode.personal
                            ? (isRTL ? 'شخصي' : 'Personal')
                            : (isRTL ? 'تجاري' : 'Business'),
                        style: (isDesktop
                                ? AppTypography.labelLarge
                                : AppTypography.labelMedium)
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (appMode == AppMode.business && currentUser != null)
                        Text(
                          currentUser!.name,
                          style: (isDesktop
                                  ? AppTypography.labelMedium
                                  : AppTypography.labelSmall)
                              .copyWith(
                                color: currentUser!.role.color,
                                fontWeight: FontWeight.w500,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: isRTL ? 'بحث' : 'Search',
            onPressed: onSearch,
          ),
          // Logout Button (Desktop only)
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.darkError : AppColors.error,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  isRTL ? 'تسجيل الخروج' : 'Logout',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
                onPressed: onLogout,
              ),
            ),
        ],
      ),
    );
  }
}
