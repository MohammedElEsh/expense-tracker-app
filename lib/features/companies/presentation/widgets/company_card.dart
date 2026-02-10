// ✅ Clean Architecture - Company Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/utils/theme_helper.dart';

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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: company.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          company.isActive ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: company.isActive ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          company.isActive
                              ? (isRTL ? 'نشط' : 'Active')
                              : (isRTL ? 'غير نشط' : 'Inactive'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: company.isActive ? Colors.green : Colors.grey,
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
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
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
                      //         color: Colors.red,
                      //         size: 18,
                      //       ),
                      //       const SizedBox(width: 8),
                      //       Text(
                      //         isRTL ? 'حذف' : 'Delete',
                      //         style: const TextStyle(color: Colors.red),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: context.iconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Company Name
              Text(
                company.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: 12),

              // Company Details
              _buildDetailRow(
                context,
                Icons.attach_money,
                isRTL ? 'العملة' : 'Currency',
                company.currency,
              ),

              if (company.taxNumber != null && company.taxNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.badge,
                  isRTL ? 'الرقم الضريبي' : 'Tax Number',
                  company.taxNumber!,
                ),
              ],

              if (company.phone != null && company.phone!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.phone,
                  isRTL ? 'الهاتف' : 'Phone',
                  company.phone!,
                ),
              ],

              if (company.address != null && company.address!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  isRTL ? 'العنوان' : 'Address',
                  company.address!,
                ),
              ],

              const SizedBox(height: 12),

              // Employee Count
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: context.iconColor),
                  const SizedBox(width: 4),
                  Text(
                    '${company.currentEmployeeCount} ${isRTL ? 'موظف' : 'employees'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (company.ownerId != null)
                    Text(
                      '${isRTL ? 'المالك:' : 'Owner:'} ${company.ownerId!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.tertiaryTextColor,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Fiscal Year
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: context.iconColor),
                  const SizedBox(width: 4),
                  Text(
                    '${isRTL ? 'بداية السنة المالية:' : 'Fiscal Year Start:'} ${company.fiscalYearStart}',
                    style: TextStyle(
                      fontSize: 12,
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
        Icon(icon, size: 16, color: context.iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

