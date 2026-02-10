// Home Feature - Presentation Layer - View Mode Selector Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/theme_helper.dart';

class ViewModeSelector extends StatelessWidget {
  final bool isRTL;
  final String currentViewMode;
  final Function(String) onViewModeChanged;

  const ViewModeSelector({
    super.key,
    required this.isRTL,
    required this.currentViewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'اختر طريقة العرض' : 'Select View Mode',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildViewModeOption(context, 'all', isRTL ? 'الكل' : 'All'),
          _buildViewModeOption(context, 'day', isRTL ? 'اليوم' : 'Day'),
          _buildViewModeOption(context, 'week', isRTL ? 'الأسبوع' : 'Week'),
          _buildViewModeOption(context, 'month', isRTL ? 'الشهر' : 'Month'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildViewModeOption(BuildContext context, String mode, String label) {
    final isSelected = currentViewMode == mode;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // أغلق الـ BottomSheet أولاً
        onViewModeChanged(mode); // ثم غيّر الوضع
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : null,
          border: Border(
            bottom: BorderSide(
              color: context.borderColor.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            if (isSelected) const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
