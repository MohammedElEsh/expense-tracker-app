// Budget Helpers - مساعدات الميزانية
import 'package:flutter/material.dart';
import 'package:expense_tracker/constants/categories.dart';

class BudgetHelpers {
  /// الحصول على لون الفئة
  static Color getCategoryColor(String category) {
    final icon = Categories.getIcon(category);

    if (icon == Icons.restaurant) return Colors.orange;
    if (icon == Icons.directions_car) return Colors.blue;
    if (icon == Icons.shopping_bag) return Colors.purple;
    if (icon == Icons.movie) return Colors.pink;
    if (icon == Icons.receipt) return Colors.red;
    if (icon == Icons.local_hospital) return Colors.green;

    return Colors.blue.shade700;
  }

  /// الحصول على أيقونة الفئة
  static IconData getCategoryIcon(String category) {
    return Categories.getIcon(category);
  }

  /// حساب النسبة المئوية للميزانية المستخدمة
  static double calculatePercentage(double spent, double limit) {
    return limit > 0 ? (spent / limit) * 100 : 0.0;
  }

  /// هل تجاوزت الميزانية؟
  static bool isOverBudget(double spent, double limit) {
    return spent > limit;
  }

  /// هل قريبة من الحد؟
  static bool isNearLimit(double spent, double limit) {
    final percentage = calculatePercentage(spent, limit);
    return percentage >= 80 && !isOverBudget(spent, limit);
  }

  /// الحصول على لون الحالة
  static Color getStatusColor(double spent, double limit) {
    if (isOverBudget(spent, limit)) return Colors.red;
    if (isNearLimit(spent, limit)) return Colors.orange;
    return Colors.green;
  }

  /// الحصول على نص الحالة
  static String getStatusText(double spent, double limit, bool isRTL) {
    if (isOverBudget(spent, limit)) {
      return isRTL ? 'تجاوزت الميزانية!' : 'Over Budget!';
    }
    if (isNearLimit(spent, limit)) {
      return isRTL ? 'قريب من الحد' : 'Near Limit';
    }
    return isRTL ? 'ضمن الميزانية' : 'Within Budget';
  }
}
