// Home Feature - Presentation Layer - BLoC State
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final String viewMode; // 'day', 'week', 'month', 'all'
  final DateTime selectedDate;
  final bool isSearchVisible;
  final bool isLoggingOut;
  final String? logoutError;

  HomeState({
    this.viewMode = 'all',
    DateTime? selectedDate,
    this.isSearchVisible = false,
    this.isLoggingOut = false,
    this.logoutError,
  }) : selectedDate = selectedDate ?? DateTime.now();

  @override
  List<Object?> get props => [
    viewMode,
    selectedDate,
    isSearchVisible,
    isLoggingOut,
    logoutError,
  ];

  HomeState copyWith({
    String? viewMode,
    DateTime? selectedDate,
    bool? isSearchVisible,
    bool? isLoggingOut,
    String? logoutError,
    bool clearError = false,
  }) {
    return HomeState(
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      logoutError: clearError ? null : (logoutError ?? this.logoutError),
    );
  }
}
