// App-level shell: main navigation drawer (not in core; feature-specific menu).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_state.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/presentation/utils/user_role_display.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AppDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            final isRTL = settings.language == 'ar';
            final currentUser = userState is UserLoaded ? userState.currentUser : null;
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
                      _buildDrawerHeader(
                        context,
                        settings,
                        currentUser,
                        appMode,
                        isRTL,
                      ),
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
                      Divider(height: AppSpacing.xxl, thickness: 1),
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
                      Divider(height: AppSpacing.xxl, thickness: 1),
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
                        badgeColor: AppColors.error,
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
                        badgeColor: AppColors.badgePremium,
                        onTap: () => _handleSubscription(context, isRTL),
                        settings: settings,
                      ),
                      Divider(height: AppSpacing.xxl, thickness: 1),
                      _buildDrawerTile(
                        context,
                        icon: Icons.logout,
                        title: isRTL ? 'تسجيل الخروج' : 'Logout',
                        iconColor: AppColors.error,
                        textColor: AppColors.error,
                        onTap: () => _handleLogout(context, isRTL),
                        settings: settings,
                      ),
                      const SizedBox(height: AppSpacing.md),
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
    UserEntity? currentUser,
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
        style: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      accountEmail: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color:
                  appMode == AppMode.personal
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  appMode == AppMode.personal ? Icons.person : Icons.business,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  appMode == AppMode.personal
                      ? (isRTL ? 'شخصي' : 'Personal')
                      : (isRTL ? 'تجاري' : 'Business'),
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (appMode == AppMode.business && currentUser != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: currentUser.role.color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                currentUser.role.getDisplayName(isRTL),
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: settings.primaryColor),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: badgeColor ?? settings.primaryColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  badge,
                  style: AppTypography.overline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Icon(
                Icons.chevron_right,
                color: settings.primaryTextColor.withValues(alpha: 0.3),
              ),
      onTap: () {
        context.pop();
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
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: settings.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          color: settings.primaryColor,
          size: AppSpacing.iconMd,
        ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs + 2,
                vertical: AppSpacing.xxxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                badge,
                style: AppTypography.overline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: settings.primaryTextColor.withValues(alpha: 0.6),
        ),
      ),
      onTap: () {
        context.pop();
        onTap();
      },
    );
  }

  void _handleAddExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final vendorCubit = context.read<VendorCubit>();
        final vendorNames =
            vendorCubit.state.vendors.map((v) => v.name).toList();
        return AddExpenseDialog.createWithCubit(
          context,
          selectedDate: DateTime.now(),
          projects: null,
          vendorNames: vendorNames.isEmpty ? null : vendorNames,
        );
      },
    );
  }

  void _handleOCRScanner(BuildContext context, bool isRTL) {
    context.push(AppRoutes.ocrScanner);
  }

  void _handleAddAccount(BuildContext context, bool isRTL) {
    context.push(AppRoutes.accounts);
  }

  void _navigateToAccounts(BuildContext context) {
    context.push(AppRoutes.accounts);
  }

  void _navigateToRecurringExpenses(BuildContext context) {
    context.push(AppRoutes.recurringExpenses);
  }

  void _navigateToCompanies(BuildContext context) {
    context.push(AppRoutes.companies);
  }

  void _navigateToProjects(BuildContext context) {
    context.push(AppRoutes.projects);
  }

  void _navigateToVendors(BuildContext context) {
    context.push(AppRoutes.vendors);
  }

  void _handleNotifications(BuildContext context, bool isRTL) {
    context.push(AppRoutes.notifications);
  }

  void _handleSubscription(BuildContext context, bool isRTL) {
    context.push(AppRoutes.subscription);
  }

  Future<void> _handleLogout(BuildContext context, bool isRTL) async {
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
                onPressed: () => dialogContext.pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => dialogContext.pop(true),
                child: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      if (context.mounted && context.canPop()) {
        context.pop();
      }
      onLogout();
    }
  }
}
