// ✅ Clean Architecture - Vendor Card Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/utils/theme_helper.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
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
                  // Type Indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: vendor.type.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      vendor.type.icon,
                      color: vendor.type.color,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: vendor.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vendor.status.getDisplayName(isRTL),
                      style: TextStyle(
                        fontSize: 11,
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
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isRTL ? 'حذف' : 'Delete',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
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

              // Vendor Name
              Text(
                vendor.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
              ),

              const SizedBox(height: 4),

              // Type
              Text(
                vendor.type.getDisplayName(isRTL),
                style: TextStyle(
                  fontSize: 13,
                  color: vendor.type.color,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // Contact Info
              if (vendor.contactInfo != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.contact_phone,
                      size: 16,
                      color: context.iconColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vendor.contactInfo!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Address
              if (vendor.address?.isNotEmpty == true) ...[
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: context.iconColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        vendor.address!,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Financial Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.backgroundCardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRTL ? 'إجمالي المصروفات:' : 'Total Spent:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${vendor.totalSpent.toStringAsFixed(2)} ر.س',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: context.infoColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isRTL ? 'عدد المعاملات:' : 'Transactions:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.secondaryTextColor,
                          ),
                        ),
                        Text(
                          '${vendor.transactionCount}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.successColor,
                          ),
                        ),
                      ],
                    ),

                    if (vendor.transactionCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRTL ? 'متوسط المعاملة:' : 'Avg Transaction:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.secondaryTextColor,
                            ),
                          ),
                          Text(
                            '${vendor.averageTransactionValue.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontSize: 14,
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

              const SizedBox(height: 12),

              // Last Transaction
              if (vendor.lastTransactionDate != null) ...[
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: context.iconColor),
                    const SizedBox(width: 6),
                    Text(
                      '${isRTL ? 'آخر معاملة:' : 'Last transaction:'} ${_formatLastTransaction()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.tertiaryTextColor,
                      ),
                    ),
                    const Spacer(),

                    // Days since last transaction
                    if (vendor.daysSinceLastTransaction != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getLastTransactionColor().withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${vendor.daysSinceLastTransaction} ${isRTL ? 'يوم' : 'days ago'}',
                          style: TextStyle(
                            fontSize: 10,
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
    if (days == null) return Colors.grey;

    if (days <= 7) return Colors.green;
    if (days <= 30) return Colors.orange;
    return Colors.red;
  }
}
