// ✅ Enhanced Statistics Screen - Refactored (Main Screen Only)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/weekly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/monthly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/yearly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/advanced_analysis_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/business_reports_tab.dart';

class EnhancedStatisticsScreen extends StatefulWidget {
  const EnhancedStatisticsScreen({super.key});

  @override
  State<EnhancedStatisticsScreen> createState() =>
      _EnhancedStatisticsScreenState();
}

class _EnhancedStatisticsScreenState extends State<EnhancedStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedYear = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, expenseState) {
            final isRTL = settings.language == 'ar';

            return Directionality(
              textDirection:
                  isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: _buildAppBar(isRTL),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    WeeklyStatisticsTab(
                      expenseState: expenseState,
                      settings: settings,
                      isRTL: isRTL,
                    ),
                    MonthlyStatisticsTab(
                      expenseState: expenseState,
                      settings: settings,
                      isRTL: isRTL,
                      selectedMonth: _selectedMonth,
                    ),
                    YearlyStatisticsTab(
                      expenseState: expenseState,
                      settings: settings,
                      isRTL: isRTL,
                      selectedYear: _selectedYear,
                    ),
                    AdvancedAnalysisTab(
                      expenseState: expenseState,
                      settings: settings,
                      isRTL: isRTL,
                    ),
                    BusinessReportsTab(
                      expenseState: expenseState,
                      settings: settings,
                      isRTL: isRTL,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isRTL) {
    return AppBar(
      title: Text(
        isRTL ? 'الإحصائيات المتقدمة' : 'Enhanced Analytics',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: () => _showDatePicker(context, isRTL),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          Tab(
            icon: const Icon(Icons.bar_chart),
            text: isRTL ? 'أسبوعي' : 'Weekly',
          ),
          Tab(
            icon: const Icon(Icons.pie_chart),
            text: isRTL ? 'شهري' : 'Monthly',
          ),
          Tab(
            icon: const Icon(Icons.trending_up),
            text: isRTL ? 'سنوي' : 'Yearly',
          ),
          Tab(
            icon: const Icon(Icons.analytics),
            text: isRTL ? 'تحليل' : 'Analysis',
          ),
          Tab(
            icon: const Icon(Icons.business),
            text: isRTL ? 'تجاري' : 'Business',
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context, bool isRTL) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _selectedYear = DateTime(picked.year);
      });
    }
  }
}
