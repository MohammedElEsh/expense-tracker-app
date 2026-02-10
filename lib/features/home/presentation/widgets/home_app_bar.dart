// Home Feature - Presentation Layer - Home AppBar Widget
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 22 : (isTablet ? 20 : 16),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isDesktop ? 16 : 8),
            // User info على اليمين - مضغوط
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Mode Icon
                Container(
                  width: isDesktop ? 32 : 28,
                  height: isDesktop ? 32 : 28,
                  decoration: BoxDecoration(
                    color:
                        appMode == AppMode.personal
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    appMode == AppMode.personal ? Icons.person : Icons.business,
                    color:
                        appMode == AppMode.personal
                            ? Colors.green
                            : Colors.blue,
                    size: isDesktop ? 18 : 16,
                  ),
                ),
                SizedBox(width: isDesktop ? 10 : 6),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 14 : 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (appMode == AppMode.business && currentUser != null)
                        Text(
                          currentUser!.name,
                          style: TextStyle(
                            color: currentUser!.role.color,
                            fontWeight: FontWeight.w500,
                            fontSize: isDesktop ? 12 : 10,
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  isRTL ? 'تسجيل الخروج' : 'Logout',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: onLogout,
              ),
            ),
        ],
      ),
    );
  }
}
