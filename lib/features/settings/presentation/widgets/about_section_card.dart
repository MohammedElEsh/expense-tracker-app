// Settings - About Section Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'modern_settings_card.dart';

class AboutSectionCard extends StatelessWidget {
  final SettingsState settings;
  final bool isRTL;

  const AboutSectionCard({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return ModernSettingsCard(
      title: isRTL ? 'حول التطبيق' : 'About App',
      icon: Icons.info,
      iconColor: Colors.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(isRTL ? 'الإصدار' : 'Version', '1.0.0'),
          const Divider(height: 24),
          _buildInfoRow(isRTL ? 'المطور' : 'Developer', 'Expense Tracker Team'),
          const Divider(height: 24),
          _buildInfoRow(
            isRTL ? 'البريد الإلكتروني' : 'Email',
            'support@expensetracker.com',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Show license dialog
                showLicensePage(
                  context: context,
                  applicationName: 'Expense Tracker',
                  applicationVersion: '1.0.0',
                );
              },
              icon: const Icon(Icons.article),
              label: Text(isRTL ? 'التراخيص' : 'Licenses'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: settings.secondaryTextColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: settings.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
