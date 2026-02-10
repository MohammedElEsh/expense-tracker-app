// Statistics Feature - Cubit State
import 'package:equatable/equatable.dart';

class StatisticsState extends Equatable {
  final int selectedTabIndex;
  final int selectedYear;
  final int selectedMonth;
  final bool isLoading;
  final String? error;

  StatisticsState({
    this.selectedTabIndex = 0,
    int? selectedYear,
    int? selectedMonth,
    this.isLoading = false,
    this.error,
  }) : selectedYear = selectedYear ?? DateTime.now().year,
       selectedMonth = selectedMonth ?? DateTime.now().month;

  @override
  List<Object?> get props => [
    selectedTabIndex,
    selectedYear,
    selectedMonth,
    isLoading,
    error,
  ];

  StatisticsState copyWith({
    int? selectedTabIndex,
    int? selectedYear,
    int? selectedMonth,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StatisticsState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
