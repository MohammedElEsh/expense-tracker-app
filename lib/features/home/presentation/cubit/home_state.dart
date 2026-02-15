// Home Feature - Presentation Layer - Cubit State
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class HomeState extends Equatable {
  final String viewMode; // 'day', 'week', 'month', 'all'
  final DateTime selectedDate;
  final bool isSearchVisible;
  final bool isLoggingOut;
  final String? logoutError;
  /// View-mode filtered expenses and total; computed by HomeCubit via use cases.
  final List<Expense> filteredExpenses;
  final double totalAmount;

  HomeState({
    this.viewMode = 'all',
    DateTime? selectedDate,
    this.isSearchVisible = false,
    this.isLoggingOut = false,
    this.logoutError,
    this.filteredExpenses = const [],
    this.totalAmount = 0.0,
  }) : selectedDate = selectedDate ?? DateTime.now();

  @override
  List<Object?> get props => [
    viewMode,
    selectedDate,
    isSearchVisible,
    isLoggingOut,
    logoutError,
    filteredExpenses,
    totalAmount,
  ];

  HomeState copyWith({
    String? viewMode,
    DateTime? selectedDate,
    bool? isSearchVisible,
    bool? isLoggingOut,
    String? logoutError,
    List<Expense>? filteredExpenses,
    double? totalAmount,
    bool clearError = false,
  }) {
    return HomeState(
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutError: clearError ? null : (logoutError ?? this.logoutError),
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
