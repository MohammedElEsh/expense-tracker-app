// ✅ Advanced Analysis Tab - Extracted from Enhanced Statistics Screen
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class AdvancedAnalysisTab extends StatelessWidget {
  final ExpenseState expenseState;
  final SettingsState settings;
  final bool isRTL;

  const AdvancedAnalysisTab({
    super.key,
    required this.expenseState,
    required this.settings,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = expenseState.allExpenses;

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا توجد بيانات للتحليل' : 'No data to analyze',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Calculate statistics
    final totalExpenses = expenses.length;
    final totalAmount = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    // final averageExpense = totalAmount / totalExpenses;

    // Find max and min
    final amounts = expenses.map((e) => e.amount).toList();
    amounts.sort();
    final maxExpense = amounts.last;
    // final minExpense = amounts.first;

    // Category analysis
    final Map<String, int> categoryCount = {};
    final Map<String, double> categoryTotal = {};

    for (final expense in expenses) {
      categoryCount[expense.category] =
          (categoryCount[expense.category] ?? 0) + 1;
      categoryTotal[expense.category] =
          (categoryTotal[expense.category] ?? 0) + expense.amount;
    }

    // Sort categories by total amount
    final sortedCategories =
        categoryTotal.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate daily average
    final daysDiff =
        expenses.isNotEmpty
            ? DateTime.now().difference(expenses.first.date).inDays + 1
            : 1;
    final dailyAverage = totalAmount / daysDiff;

    // Get top spending category
    final topCategory =
        sortedCategories.isNotEmpty ? sortedCategories.first.key : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isRTL ? 'تحليل متقدم' : 'Advanced Analysis',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          _buildStatCard(
            context,
            title: isRTL ? 'متوسط المصروف اليومي' : 'Average Daily Expense',
            value:
                '${settings.currencySymbol} ${dailyAverage.toStringAsFixed(2)}',
            icon: Icons.show_chart,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            title: isRTL ? 'أعلى فئة إنفاق' : 'Top Spending Category',
            value: topCategory,
            icon: Icons.category,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            title: isRTL ? 'أعلى مصروف' : 'Highest Expense',
            value:
                '${settings.currencySymbol} ${maxExpense.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            context,
            title: isRTL ? 'إجمالي المعاملات' : 'Total Transactions',
            value: totalExpenses.toString(),
            icon: Icons.receipt_long,
            color: Colors.purple,
          ),

          const SizedBox(height: 32),

          // Top Categories
          Text(
            isRTL ? 'الفئات الأكثر إنفاقاً' : 'Top Spending Categories',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...sortedCategories.take(5).map((entry) {
            final category = entry.key;
            final total = entry.value;
            final count = categoryCount[category] ?? 0;
            final percentage = (total / totalAmount * 100);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  child: const Icon(Icons.category, color: Colors.purple),
                ),
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('$count ${isRTL ? 'مصروف' : 'expenses'}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${settings.currencySymbol} ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Build stat card widget
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ],
      ),
    );
  }

  // Build pie chart sections for category distribution
  // ignore: unused_element
  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categoryTotal,
    double total,
  ) {
    if (total == 0) return [];

    final colors = [
      Colors.purple.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.amber.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
    ];

    return categoryTotal.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }
}

// ignore: unused_element
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
