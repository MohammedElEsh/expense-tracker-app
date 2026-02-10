// ✅ Expense Filter - Main Widget (Refactored with BLoC)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_filter_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_filter_event.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_filter_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/expense_search_bar.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/category_filter_chip.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/date_range_filter.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/amount_range_filter.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/filter/filter_summary.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';

class SearchFilterWidgetRefactored extends StatefulWidget {
  final List<Expense> expenses;
  final Function(List<Expense>) onFilteredExpenses;

  const SearchFilterWidgetRefactored({
    super.key,
    required this.expenses,
    required this.onFilteredExpenses,
  });

  @override
  State<SearchFilterWidgetRefactored> createState() =>
      _SearchFilterWidgetRefactoredState();
}

class _SearchFilterWidgetRefactoredState
    extends State<SearchFilterWidgetRefactored>
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
    final settings = context.watch<SettingsBloc>().state;
    final isRTL = settings.language == 'ar';

    return BlocProvider(
      create: (context) => ExpenseFilterBloc(allExpenses: widget.expenses),
      child: BlocConsumer<ExpenseFilterBloc, ExpenseFilterState>(
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
                  context.read<ExpenseFilterBloc>().add(
                    const ToggleFilterVisibilityEvent(),
                  );
                },
                activeFilterCount: filterState.activeFilterCount,
                onSearchChanged: (query) {
                  context.read<ExpenseFilterBloc>().add(
                    ChangeSearchQueryEvent(query),
                  );
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
                        context.read<ExpenseFilterBloc>().add(
                          ChangeCategoryFilterEvent(category),
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Date Range Filter
                    DateRangeFilter(
                      dateRange: filterState.dateRange,
                      isRTL: isRTL,
                      onDateRangeChanged: (dateRange) {
                        context.read<ExpenseFilterBloc>().add(
                          ChangeDateRangeFilterEvent(dateRange),
                        );
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
                        context.read<ExpenseFilterBloc>().add(
                          ChangeAmountRangeFilterEvent(
                            minAmount: minAmount,
                            maxAmount: filterState.maxAmount,
                          ),
                        );
                      },
                      onMaxAmountChanged: (maxAmount) {
                        context.read<ExpenseFilterBloc>().add(
                          ChangeAmountRangeFilterEvent(
                            minAmount: filterState.minAmount,
                            maxAmount: maxAmount,
                          ),
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
                  context.read<ExpenseFilterBloc>().add(
                    const ResetFiltersEvent(),
                  );
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
