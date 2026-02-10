import 'package:flutter/material.dart';

/// "Coming soon" placeholder section listing future notification features.
class ComingSoonSection extends StatelessWidget {
  const ComingSoonSection({
    super.key,
    required this.isRTL,
    required this.primaryColor,
    required this.primaryTextColor,
  });

  final bool isRTL;
  final Color primaryColor;
  final Color primaryTextColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            isRTL ? 'قريباً' : 'Coming soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),
        _FeatureItem(
          icon: Icons.warning_amber_outlined,
          text:
              isRTL
                  ? 'تنبيهات الميزانية (80% و 100%)'
                  : 'Budget alerts (80% & 100%)',
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
        ),
        _FeatureItem(
          icon: Icons.folder_open,
          text: isRTL ? 'تنبيهات مواعيد المشاريع' : 'Project deadline alerts',
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
        ),
        _FeatureItem(
          icon: Icons.check_circle_outline,
          text:
              isRTL
                  ? 'إشعارات الموافقات (تجاري)'
                  : 'Approval notifications (Business)',
          primaryColor: primaryColor,
          primaryTextColor: primaryTextColor,
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
    required this.primaryColor,
    required this.primaryTextColor,
  });

  final IconData icon;
  final String text;
  final Color primaryColor;
  final Color primaryTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: primaryTextColor.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
