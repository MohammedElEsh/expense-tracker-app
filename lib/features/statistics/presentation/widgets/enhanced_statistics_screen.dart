// Enhanced Statistics Screen: uses StatisticsCubit + SettingsCubit only.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/weekly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/monthly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/yearly_statistics_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/advanced_analysis_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/widgets/tabs/business_reports_tab.dart';
import 'package:expense_tracker/features/statistics/presentation/cubit/statistics_period.dart';

class EnhancedStatisticsScreen extends StatefulWidget {
  const EnhancedStatisticsScreen({super.key});

  @override
  State<EnhancedStatisticsScreen> createState() =>
      _EnhancedStatisticsScreenState();
}

class _EnhancedStatisticsScreenState extends State<EnhancedStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StatisticsCubit>().loadStatistics();
    });
  }

  void _onTabChanged() {
    if (!mounted) return;
    final period = _periodForIndex(_tabController.index);
    if (period != null) {
      context.read<StatisticsCubit>().selectPeriod(period);
    }
  }

  StatisticsPeriod? _periodForIndex(int index) {
    switch (index) {
      case 0:
        return StatisticsPeriod.weekly;
      case 1:
        return StatisticsPeriod.monthly;
      case 2:
        return StatisticsPeriod.yearly;
      default:
        return StatisticsPeriod.monthly;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return BlocBuilder<StatisticsCubit, StatisticsState>(
          builder: (context, state) {
            final isRTL = settings.language == 'ar';
            final selectedMonth = DateTime(state.selectedYear, state.selectedMonth);
            final selectedYear = DateTime(state.selectedYear);

            return Directionality(
              textDirection:
                  isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: _buildAppBar(context, isRTL),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    WeeklyStatisticsTab(
                      statistics: state.statistics,
                      settings: settings,
                      isRTL: isRTL,
                    ),
                    MonthlyStatisticsTab(
                      statistics: state.statistics,
                      settings: settings,
                      isRTL: isRTL,
                      selectedMonth: selectedMonth,
                    ),
                    YearlyStatisticsTab(
                      statistics: state.statistics,
                      settings: settings,
                      isRTL: isRTL,
                      selectedYear: selectedYear,
                    ),
                    AdvancedAnalysisTab(
                      statistics: state.statistics,
                      settings: settings,
                      isRTL: isRTL,
                    ),
                    BusinessReportsTab(
                      statistics: state.statistics,
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isRTL) {
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
    final state = context.read<StatisticsCubit>().state;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(state.selectedYear, state.selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      context.read<StatisticsCubit>().changeYear(picked.year);
      context.read<StatisticsCubit>().changeMonth(picked.month);
    }
  }
}
