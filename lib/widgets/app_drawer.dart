// ✅ App Drawer - Main Navigation Drawer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog_refactored.dart';
import 'package:expense_tracker/features/accounts/presentation/pages/accounts_screen.dart';
import 'package:expense_tracker/features/recurring_expenses/presentation/pages/recurring_expenses_screen.dart';
import 'package:expense_tracker/features/projects/presentation/pages/projects_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendors_screen.dart';
import 'package:expense_tracker/features/companies/presentation/pages/companies_screen.dart';
import 'package:expense_tracker/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:expense_tracker/features/ocr/presentation/pages/ocr_scanner_screen.dart';
import 'package:expense_tracker/features/subscription/presentation/pages/subscription_screen.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AppDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final isRTL = settings.language == 'ar';
            final currentUser = userState.currentUser;
            final appMode = settings.appMode;

            return Directionality(
              textDirection:
                  isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Drawer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        settings.primaryColor.withValues(alpha: 0.05),
                        settings.surfaceColor,
                      ],
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Drawer Header
                      _buildDrawerHeader(
                        context,
                        settings,
                        currentUser,
                        appMode,
                        isRTL,
                      ),

                      // Quick Actions Section
                      _buildSectionHeader(
                        isRTL ? 'إجراءات سريعة' : 'Quick Actions',
                        Icons.flash_on,
                        settings,
                        isRTL,
                      ),
                      _buildQuickActionTile(
                        context,
                        icon: Icons.add_circle_outline,
                        title: isRTL ? 'إضافة مصروف' : 'Add Expense',
                        subtitle:
                            isRTL ? 'إضافة مصروف جديد' : 'Add a new expense',
                        onTap: () => _handleAddExpense(context),
                        settings: settings,
                      ),
                      _buildQuickActionTile(
                        context,
                        icon: Icons.camera_alt_outlined,
                        title: isRTL ? 'مسح فاتورة' : 'Scan Receipt',
                        subtitle:
                            isRTL
                                ? 'استخراج البيانات بالـ OCR'
                                : 'Extract data with OCR',
                        badge: isRTL ? 'قريباً' : 'Soon',
                        onTap: () => _handleOCRScanner(context, isRTL),
                        settings: settings,
                      ),
                      _buildQuickActionTile(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: isRTL ? 'إضافة حساب' : 'Add Account',
                        subtitle:
                            isRTL
                                ? 'حساب بنكي أو نقدي'
                                : 'Bank or cash account',
                        onTap: () => _handleAddAccount(context, isRTL),
                        settings: settings,
                      ),

                      const Divider(height: 32, thickness: 1),

                      // Management Section
                      _buildSectionHeader(
                        isRTL ? 'الإدارة' : 'Management',
                        Icons.business_center,
                        settings,
                        isRTL,
                      ),
                      _buildDrawerTile(
                        context,
                        icon: Icons.account_balance,
                        title: isRTL ? 'الحسابات' : 'Accounts',
                        onTap: () => _navigateToAccounts(context),
                        settings: settings,
                      ),
                      _buildDrawerTile(
                        context,
                        icon: Icons.repeat,
                        title:
                            isRTL ? 'المصروفات المتكررة' : 'Recurring Expenses',
                        onTap: () => _navigateToRecurringExpenses(context),
                        settings: settings,
                      ),

                      // Business Mode Only
                      if (appMode == AppMode.business) ...[
                        _buildDrawerTile(
                          context,
                          icon: Icons.business,
                          title: isRTL ? 'الشركة' : 'Company',
                          onTap: () => _navigateToCompanies(context),
                          settings: settings,
                        ),
                        _buildDrawerTile(
                          context,
                          icon: Icons.folder_open,
                          title: isRTL ? 'المشاريع' : 'Projects',
                          onTap: () => _navigateToProjects(context),
                          settings: settings,
                        ),
                        _buildDrawerTile(
                          context,
                          icon: Icons.store,
                          title: isRTL ? 'الموردين' : 'Vendors',
                          onTap: () => _navigateToVendors(context),
                          settings: settings,
                        ),
                      ],

                      const Divider(height: 32, thickness: 1),

                      // New Features Section
                      _buildSectionHeader(
                        isRTL ? 'جديد' : 'New',
                        Icons.auto_awesome,
                        settings,
                        isRTL,
                      ),
                      _buildDrawerTile(
                        context,
                        icon: Icons.notifications_outlined,
                        title: isRTL ? 'الإشعارات' : 'Notifications',
                        badge: '5',
                        badgeColor: Colors.red,
                        onTap: () => _handleNotifications(context, isRTL),
                        settings: settings,
                      ),
                      _buildDrawerTile(
                        context,
                        icon: Icons.diamond_outlined,
                        title:
                            isRTL
                                ? 'الاشتراكات والخطط'
                                : 'Subscription & Plans',
                        badge: 'Premium',
                        badgeColor: Colors.amber,
                        onTap: () => _handleSubscription(context, isRTL),
                        settings: settings,
                      ),

                      const Divider(height: 32, thickness: 1),

                      // Logout
                      _buildDrawerTile(
                        context,
                        icon: Icons.logout,
                        title: isRTL ? 'تسجيل الخروج' : 'Logout',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () => _handleLogout(context, isRTL),
                        settings: settings,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    SettingsState settings,
    User? currentUser,
    AppMode appMode,
    bool isRTL,
  ) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            settings.primaryColor,
            settings.primaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          appMode == AppMode.personal ? Icons.person : Icons.business,
          size: 40,
          color: settings.primaryColor,
        ),
      ),
      accountName: Text(
        currentUser?.name ?? (isRTL ? 'مستخدم' : 'User'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  appMode == AppMode.personal
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.blue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  appMode == AppMode.personal ? Icons.person : Icons.business,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  appMode == AppMode.personal
                      ? (isRTL ? 'شخصي' : 'Personal')
                      : (isRTL ? 'تجاري' : 'Business'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (appMode == AppMode.business && currentUser != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(
                  currentUser.role.colorValue,
                ).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentUser.role.getDisplayName(isRTL),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    SettingsState settings,
    bool isRTL,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: settings.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: settings.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badge,
    Color? badgeColor,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
    required SettingsState settings,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? settings.primaryTextColor.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? settings.primaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          badge != null
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? settings.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Icon(
                Icons.chevron_right,
                color: settings.primaryTextColor.withValues(alpha: 0.3),
              ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
    required SettingsState settings,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: settings.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: settings.primaryColor, size: 24),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: settings.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: settings.primaryTextColor.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  // Navigation Handlers
  void _handleAddExpense(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) =>
              AddExpenseDialogRefactored(selectedDate: DateTime.now()),
    );
  }

  void _handleOCRScanner(BuildContext context, bool isRTL) {
    Navigator.of(context).pushWithAnimation(
      const OCRScannerScreen(),
      animationType: AnimationType.slideUp,
    );
  }

  void _handleAddAccount(BuildContext context, bool isRTL) {
    Navigator.of(context).pushWithAnimation(
      const AccountsScreen(),
      animationType: AnimationType.slideUp,
    );
  }

  void _navigateToAccounts(BuildContext context) {
    Navigator.of(context).pushWithAnimation(
      const AccountsScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _navigateToRecurringExpenses(BuildContext context) {
    Navigator.of(context).pushWithAnimation(
      const RecurringExpensesScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _navigateToCompanies(BuildContext context) {
    Navigator.of(context).pushWithAnimation(
      const CompaniesScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _navigateToProjects(BuildContext context) {
    Navigator.of(context).pushWithAnimation(
      const ProjectsScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _navigateToVendors(BuildContext context) {
    Navigator.of(context).pushWithAnimation(
      const VendorsScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _handleNotifications(BuildContext context, bool isRTL) {
    Navigator.of(context).pushWithAnimation(
      const NotificationsScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  void _handleSubscription(BuildContext context, bool isRTL) {
    Navigator.of(context).pushWithAnimation(
      const SubscriptionScreen(),
      animationType: AnimationType.slideRight,
    );
  }

  Future<void> _handleLogout(BuildContext context, bool isRTL) async {
    // عرض dialog التأكيد
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من تسجيل الخروج؟'
                  : 'Are you sure you want to logout?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Close drawer first (only if context is still valid)
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }

      // Call the parent's logout handler (doesn't need context)
      onLogout();
    }
  }
}
