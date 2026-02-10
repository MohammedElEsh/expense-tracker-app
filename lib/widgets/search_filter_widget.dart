import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class SearchFilterWidget extends StatefulWidget {
  final List<Expense> expenses;
  final Function(List<Expense>) onFilteredExpenses;
  final bool isRTL;

  const SearchFilterWidget({
    super.key,
    required this.expenses,
    required this.onFilteredExpenses,
    required this.isRTL,
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

  bool _isFilterVisible = false;
  String _searchQuery = '';
  String? _selectedCategory;
  DateTimeRange? _dateRange;
  double? _minAmount;
  double? _maxAmount;

  // Legacy widget with hardcoded English categories
  // Reorder to ensure "Others" is always last (matching Arabic "أخرى" behavior)
  List<String> get _categories {
    final categories = [
      'Food',
      'Transportation',
      'Entertainment',
      'Shopping',
      'Bills',
      'Healthcare',
      'Others',
    ];
    // Move "Others" to the end if it exists
    final reordered = List<String>.from(categories);
    if (reordered.contains('Others')) {
      reordered.remove('Others');
      reordered.add('Others');
    }
    return reordered;
  }

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

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Expense> filtered =
        widget.expenses.where((expense) {
          // Search filter
          bool matchesSearch = true;
          if (_searchQuery.isNotEmpty) {
            matchesSearch =
                expense.notes.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                expense.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }

          // Category filter
          bool matchesCategory =
              _selectedCategory == null ||
              expense.category == _selectedCategory;

          // Date range filter
          bool matchesDateRange = true;
          if (_dateRange != null) {
            matchesDateRange =
                expense.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(
                  _dateRange!.end.add(const Duration(days: 1)),
                );
          }

          // Amount range filter
          bool matchesAmount = true;
          if (_minAmount != null) {
            matchesAmount = matchesAmount && expense.amount >= _minAmount!;
          }
          if (_maxAmount != null) {
            matchesAmount = matchesAmount && expense.amount <= _maxAmount!;
          }

          return matchesSearch &&
              matchesCategory &&
              matchesDateRange &&
              matchesAmount;
        }).toList();

    widget.onFilteredExpenses(filtered);
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });

    if (_isFilterVisible) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _dateRange = null;
      _minAmount = null;
      _maxAmount = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        return Directionality(
          textDirection:
              widget.isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText:
                        widget.isRTL
                            ? 'البحث في المصروفات...'
                            : 'Search expenses...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocus.unfocus();
                            },
                          ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color:
                                _hasActiveFilters()
                                    ? Colors.blue
                                    : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color:
                                  _hasActiveFilters()
                                      ? Colors.white
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: _toggleFilter,
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              // Filter panel
              AnimatedBuilder(
                animation: _filterAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: _filterAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Filter header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.isRTL
                                      ? 'تصفية النتائج'
                                      : 'Filter Results',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_hasActiveFilters())
                                  TextButton(
                                    onPressed: _clearAllFilters,
                                    child: Text(
                                      widget.isRTL ? 'مسح الكل' : 'Clear All',
                                      style: TextStyle(color: Colors.blue[600]),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Category filter
                            Text(
                              widget.isRTL ? 'الفئة' : 'Category',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children:
                                  _categories.map((category) {
                                    final isSelected =
                                        _selectedCategory == category;
                                    return FilterChip(
                                      label: Text(
                                        Categories.getDisplayName(category, widget.isRTL),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedCategory =
                                              selected ? category : null;
                                        });
                                        _applyFilters();
                                      },
                                      selectedColor: Colors.blue[100],
                                      checkmarkColor: Colors.blue[700],
                                    );
                                  }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Date range filter
                            Text(
                              widget.isRTL ? 'نطاق التاريخ' : 'Date Range',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDateRange,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _dateRange != null
                                            ? '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}'
                                            : (widget.isRTL
                                                ? 'اختر نطاق التاريخ'
                                                : 'Select date range'),
                                        style: TextStyle(
                                          color:
                                              _dateRange != null
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    if (_dateRange != null)
                                      IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _dateRange = null;
                                          });
                                          _applyFilters();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Amount range filter
                            Text(
                              widget.isRTL ? 'نطاق المبلغ' : 'Amount Range',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: widget.isRTL ? 'من' : 'Min',
                                      border: const OutlineInputBorder(),
                                      prefixText: settings.currencySymbol,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (value) {
                                      setState(() {
                                        _minAmount = double.tryParse(value);
                                      });
                                      _applyFilters();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: widget.isRTL ? 'إلى' : 'Max',
                                      border: const OutlineInputBorder(),
                                      prefixText: settings.currencySymbol,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (value) {
                                      setState(() {
                                        _maxAmount = double.tryParse(value);
                                      });
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _dateRange != null ||
        _minAmount != null ||
        _maxAmount != null;
  }


  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }
}
