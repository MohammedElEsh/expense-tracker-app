// Settings - App Mode Settings Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'modern_settings_card.dart';

class AppModeSettingsCard extends StatelessWidget {
  final SettingsState settings;
  final bool isRTL;

  const AppModeSettingsCard({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return ModernSettingsCard(
      title: isRTL ? 'وضع التطبيق' : 'App Mode',
      icon: Icons.business,
      iconColor: Colors.purple,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: settings.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: settings.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              settings.appMode == AppMode.business
                  ? Icons.business
                  : Icons.person,
              color: settings.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL
                        ? 'الوضع الحالي: ${settings.appMode.displayName(isRTL)}'
                        : 'Current Mode: ${settings.appMode.displayName(isRTL)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: settings.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRTL
                        ? 'لتغيير الوضع، قم بتسجيل الخروج ثم سجل دخول بالحساب المناسب.'
                        : 'To change mode, logout and sign in with the desired account.',
                    style: TextStyle(
                      fontSize: 12,
                      color: settings.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
