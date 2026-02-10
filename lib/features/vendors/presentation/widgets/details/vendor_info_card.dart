import 'package:flutter/material.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class VendorInfoCard extends StatelessWidget {
  final Vendor vendor;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const VendorInfoCard({
    super.key,
    required this.vendor,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: settings.borderColor),
        boxShadow: [
          BoxShadow(
            color:
                settings.isDarkMode
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'معلومات المورد' : 'Vendor Information',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          if (vendor.contactPerson?.isNotEmpty == true)
            _buildInfoRow(
              Icons.person,
              isRTL ? 'الشخص المسؤول' : 'Contact Person',
              vendor.contactPerson!,
            ),
          if (vendor.contactPerson?.isNotEmpty == true)
            const SizedBox(height: 12),
          if (vendor.email?.isNotEmpty == true)
            _buildInfoRow(
              Icons.email,
              isRTL ? 'البريد الإلكتروني' : 'Email',
              vendor.email!,
            ),
          if (vendor.email?.isNotEmpty == true) const SizedBox(height: 12),
          if (vendor.phone?.isNotEmpty == true)
            _buildInfoRow(
              Icons.phone,
              isRTL ? 'رقم الهاتف' : 'Phone',
              vendor.phone!,
            ),
          if (vendor.phone?.isNotEmpty == true) const SizedBox(height: 12),
          if (vendor.address?.isNotEmpty == true)
            _buildInfoRow(
              Icons.location_on,
              isRTL ? 'العنوان' : 'Address',
              vendor.address!,
            ),
          if (vendor.address?.isNotEmpty == true) const SizedBox(height: 12),
          _buildInfoRow(
            Icons.category,
            isRTL ? 'التصنيف' : 'Category',
            vendor.category.toString().split('.').last,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: isDesktop ? 20 : 18,
          color: settings.secondaryTextColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  color: settings.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: settings.primaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
