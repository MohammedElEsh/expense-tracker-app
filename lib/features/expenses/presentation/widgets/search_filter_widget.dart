// ✅ Expense Filter - Main Widget (Refactored with BLoC)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_filter_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_filter_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/expense_search_bar.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/category_filter_chip.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/date_range_filter.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/amount_range_filter.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/filter_summary.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';

class SearchFilterWidget extends StatefulWidget {
  final List<Expense> expenses;
  final Function(List<Expense>) onFilteredExpenses;

  const SearchFilterWidget({
    super.key,
    required this.expenses,
    required this.onFilteredExpenses,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final isRTL = settings.language == 'ar';

    return BlocProvider(
      create: (context) => ExpenseFilterCubit(allExpenses: widget.expenses),
      child: BlocConsumer<ExpenseFilterCubit, ExpenseFilterState>(
        listener: (context, state) {
          // تحديث المصروفات المفلترة
          widget.onFilteredExpenses(state.filteredExpenses);

          // تحديث animation الفلاتر
          if (state.isFilterVisible) {
            _filterAnimationController.forward();
          } else {
            _filterAnimationController.reverse();
          }
        },
        builder: (context, filterState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Bar
              ExpenseSearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                isRTL: isRTL,
                onFilterToggle: () {
                  context.read<ExpenseFilterCubit>().toggleFilterVisibility();
                },
                activeFilterCount: filterState.activeFilterCount,
                onSearchChanged: (query) {
                  context.read<ExpenseFilterCubit>().changeSearchQuery(query);
                },
              ),

              // Filters Section (Animated)
              SizeTransition(
                sizeFactor: _filterAnimation,
                axisAlignment: -1.0,
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Category Filter
                    CategoryFilterChip(
                      selectedCategory: filterState.selectedCategory,
                      categories: _categories,
                      isRTL: isRTL,
                      onCategoryChanged: (category) {
                        context.read<ExpenseFilterCubit>().changeCategoryFilter(
                          category,
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Date Range Filter
                    DateRangeFilter(
                      dateRange: filterState.dateRange,
                      isRTL: isRTL,
                      onDateRangeChanged: (dateRange) {
                        context
                            .read<ExpenseFilterCubit>()
                            .changeDateRangeFilter(dateRange);
                      },
                    ),

                    const SizedBox(height: 8),

                    // Amount Range Filter
                    AmountRangeFilter(
                      minAmount: filterState.minAmount,
                      maxAmount: filterState.maxAmount,
                      isRTL: isRTL,
                      currencySymbol: settings.currencySymbol,
                      onMinAmountChanged: (minAmount) {
                        context
                            .read<ExpenseFilterCubit>()
                            .changeAmountRangeFilter(
                              minAmount: minAmount,
                              maxAmount: filterState.maxAmount,
                            );
                      },
                      onMaxAmountChanged: (maxAmount) {
                        context
                            .read<ExpenseFilterCubit>()
                            .changeAmountRangeFilter(
                              minAmount: filterState.minAmount,
                              maxAmount: maxAmount,
                            );
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Filter Summary
              FilterSummary(
                filteredCount: filterState.totalCount,
                totalCount: widget.expenses.length,
                totalAmount: filterState.totalAmount,
                currencySymbol: settings.currencySymbol,
                isRTL: isRTL,
                onResetFilters: () {
                  _searchController.clear();
                  context.read<ExpenseFilterCubit>().resetFilters();
                },
                hasActiveFilters: filterState.hasActiveFilters,
              ),
            ],
          );
        },
      ),
    );
  }
}
