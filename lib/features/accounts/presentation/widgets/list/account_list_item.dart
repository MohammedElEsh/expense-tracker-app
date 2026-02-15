// Accounts - Account List Item Widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_state.dart';
import 'package:expense_tracker/features/accounts/presentation/utils/account_type_display.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';

class AccountListItem extends StatelessWidget {
  final AccountEntity account;
  final AccountState accountState;
  final bool isRTL;
  final Function(String, AccountEntity) onAction;

  const AccountListItem({
    super.key,
    required this.account,
    required this.accountState,
    required this.isRTL,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.accountDetails, extra: account);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                    color: account.type.defaultColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      account.type.icon,
                      color: account.type.defaultColor,
                      size: AppSpacing.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                account.isActive
                                    ? null
                                    : AppColors.textTertiaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxs),
                        BlocBuilder<SettingsCubit, SettingsState>(
                          builder: (context, settings) {
                            return Text(
                              account.type.displayName,
                              style: AppTypography.bodyMedium.copyWith(
                                color:
                                    settings.isDarkMode
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildPopupMenu(context),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settings) {
                  final isDarkMode = settings.isDarkMode;
                  return Text(
                    '${account.balance.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: AppTypography.amountMedium.copyWith(
                      color:
                          account.balance >= 0
                              ? (isDarkMode
                                  ? AppColors.darkSuccess
                                  : AppColors.success)
                              : (isDarkMode
                                  ? AppColors.darkError
                                  : AppColors.error),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => onAction(value, account),
      itemBuilder:
          (context) => [
            // PopupMenuItem(
            //   value: 'details',
            //   child: Row(
            //     children: [
            //       const Icon(Icons.info_outline),
            //       const SizedBox(width: 8),
            //       Text(isRTL ? 'عرض التفاصيل' : 'View Details'),
            //     ],
            //   ),
            // ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: AppSpacing.xs),
                  Text(isRTL ? 'تعديل' : 'Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Builder(
                builder: (context) {
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  final deleteColor =
                      isDarkMode ? AppColors.darkError : AppColors.error;
                  return Row(
                    children: [
                      Icon(Icons.delete, color: deleteColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isRTL ? 'حذف' : 'Delete',
                        style: TextStyle(color: deleteColor),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
    );
  }
}
