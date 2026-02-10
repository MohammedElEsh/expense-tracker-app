// ✅ Clean Architecture - Company Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/theme_helper.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final bool isRTL;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompanyCard({
    super.key,
    required this.company,
    required this.isRTL,
    required this.onTap,
    required this.onEdit,
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
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color:
                          company.isActive
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.badgeInactive.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          company.isActive ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color:
                              company.isActive
                                  ? AppColors.success
                                  : AppColors.badgeInactive,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          company.isActive
                              ? (isRTL ? 'نشط' : 'Active')
                              : (isRTL ? 'غير نشط' : 'Inactive'),
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                company.isActive
                                    ? AppColors.success
                                    : AppColors.badgeInactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Menu Button
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 18),
                                const SizedBox(width: AppSpacing.xs),
                                Text(isRTL ? 'تعديل' : 'Edit'),
                              ],
                            ),
                          ),
                          // PopupMenuItem(
                          //   value: 'delete',
                          //   child: Row(
                          //     children: [
                          //       const Icon(
                          //         Icons.delete,
                          //         color: AppColors.error,
                          //         size: 18,
                          //       ),
                          //       const SizedBox(width: AppSpacing.xs),
                          //       Text(
                          //         isRTL ? 'حذف' : 'Delete',
                          //         style: const TextStyle(color: AppColors.error),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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

              // Company Name
              Text(
                company.name,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Company Details
              _buildDetailRow(
                context,
                Icons.attach_money,
                isRTL ? 'العملة' : 'Currency',
                company.currency,
              ),

              if (company.taxNumber != null &&
                  company.taxNumber!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildDetailRow(
                  context,
                  Icons.badge,
                  isRTL ? 'الرقم الضريبي' : 'Tax Number',
                  company.taxNumber!,
                ),
              ],

              if (company.phone != null && company.phone!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildDetailRow(
                  context,
                  Icons.phone,
                  isRTL ? 'الهاتف' : 'Phone',
                  company.phone!,
                ),
              ],

              if (company.address != null && company.address!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  isRTL ? 'العنوان' : 'Address',
                  company.address!,
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              // Employee Count
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: AppSpacing.iconXs,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${company.currentEmployeeCount} ${isRTL ? 'موظف' : 'employees'}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const Spacer(),
                  if (company.ownerId != null)
                    Text(
                      '${isRTL ? 'المالك:' : 'Owner:'} ${company.ownerId!.name}',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.tertiaryTextColor,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.xs),

              // Fiscal Year
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: context.iconColor,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '${isRTL ? 'بداية السنة المالية:' : 'Fiscal Year Start:'} ${company.fiscalYearStart}',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.tertiaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconXs, color: context.iconColor),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '$label: $value',
            style: AppTypography.bodyMedium.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
