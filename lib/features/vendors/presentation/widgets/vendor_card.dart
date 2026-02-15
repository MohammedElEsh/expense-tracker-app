import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/presentation/utils/vendor_display_helper.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/theme_helper.dart';

class VendorCard extends StatelessWidget {
  final VendorEntity vendor;
  final bool isRTL;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const VendorCard({
    super.key,
    required this.vendor,
    required this.isRTL,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationMd,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Type Indicator
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: vendor.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      vendor.type.icon,
                      color: vendor.type.color,
                      size: AppSpacing.iconSm,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: vendor.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      vendor.status.displayName(isRTL),
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: vendor.status.color,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Menu Button
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isRTL ? 'حذف' : 'Delete',
                                  style: const TextStyle(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                    child: Icon(
                      Icons.more_vert,
                      color: context.iconColor,
                      size: AppSpacing.iconSm,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                vendor.displayName,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: AppSpacing.xxs),

              Text(
                vendor.type.displayName(isRTL),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: vendor.type.color,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Contact Info
              if (vendor.contactInfo != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.contact_phone,
                      size: AppSpacing.iconXs,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vendor.contactInfo!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ],

              // Address
              if (vendor.address?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppSpacing.iconXs,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vendor.address!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
              ],

              // Financial Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.backgroundCardColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRTL ? 'إجمالي المصروفات:' : 'Total Spent:',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${vendor.totalSpent.toStringAsFixed(2)} ر.س',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.infoColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRTL ? 'عدد المعاملات:' : 'Transactions:',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: context.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${vendor.transactionCount}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.successColor,
                          ),
                        ),
                      ],
                    ),

                    if (vendor.transactionCount > 0) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRTL ? 'متوسط المعاملة:' : 'Avg Transaction:',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.secondaryTextColor,
                            ),
                          ),
                          Text(
                            '${vendor.averageTransactionValue.toStringAsFixed(0)} ر.س',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  context.isDarkMode
                                      ? Colors.purple[300]
                                      : Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Last Transaction
              if (vendor.lastTransactionDate != null) ...[
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: context.iconColor),
                    const SizedBox(width: 6),
                    Text(
                      '${isRTL ? 'آخر معاملة:' : 'Last transaction:'} ${_formatLastTransaction()}',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.tertiaryTextColor,
                      ),
                    ),
                    const Spacer(),

                    // Days since last transaction
                    if (vendor.daysSinceLastTransaction != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: AppSpacing.xxxs,
                        ),
                        decoration: BoxDecoration(
                          color: _getLastTransactionColor().withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${vendor.daysSinceLastTransaction} ${isRTL ? 'يوم' : 'days ago'}',
                          style: AppTypography.overline.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getLastTransactionColor(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastTransaction() {
    if (vendor.lastTransactionDate == null) return '';
    return DateFormat('MMM dd, yyyy').format(vendor.lastTransactionDate!);
  }

  Color _getLastTransactionColor() {
    final days = vendor.daysSinceLastTransaction;
    if (days == null) return AppColors.iconLight;

    if (days <= 7) return AppColors.success;
    if (days <= 30) return AppColors.warning;
    return AppColors.error;
  }
}
