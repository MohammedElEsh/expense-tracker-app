import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class UserEmptyState extends StatelessWidget {
  const UserEmptyState({
    super.key,
    required this.isRTL,
    required this.canManage,
  });

  final bool isRTL;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.isDarkMode;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isRTL ? 'لا يوجد مستخدمين' : 'No users found',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (canManage)
                Text(
                  isRTL
                      ? 'اضغط على زر + لإضافة مستخدم جديد'
                      : 'Press + button to add a new user',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
