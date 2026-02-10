// Settings - Theme Settings Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'modern_settings_card.dart';

class ThemeSettingsCard extends StatelessWidget {
  final bool isRTL;

  const ThemeSettingsCard({super.key, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsBloc>().state;

    return ModernSettingsCard(
      title: isRTL ? 'المظهر' : 'Theme',
      icon: Icons.palette,
      iconColor: Colors.purple,
      child: Row(
        children: [
          Expanded(
            child: _buildThemeOption(
              context,
              settings,
              isRTL,
              isDark: false,
              icon: Icons.light_mode,
              label: isRTL ? 'فاتح' : 'Light',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildThemeOption(
              context,
              settings,
              isRTL,
              isDark: true,
              icon: Icons.dark_mode,
              label: isRTL ? 'داكن' : 'Dark',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsState settings,
    bool isRTL, {
    required bool isDark,
    required IconData icon,
    required String label,
  }) {
    final isSelected = settings.isDarkMode == isDark;

    return InkWell(
      onTap: () {
        // Toggle theme based on current state
        context.read<SettingsBloc>().add(ToggleDarkMode(!settings.isDarkMode));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? settings.primaryColor.withValues(alpha: 0.1)
                  : settings.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? settings.primaryColor : settings.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? settings.primaryColor
                      : settings.secondaryTextColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? settings.primaryColor
                        : settings.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
