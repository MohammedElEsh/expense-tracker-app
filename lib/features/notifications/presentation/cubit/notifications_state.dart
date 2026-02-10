// Notifications Feature - Cubit State
import 'package:equatable/equatable.dart';

class NotificationsState extends Equatable {
  final bool isLoading;
  final String? error;
  final String? selectedFilter;

  const NotificationsState({
    this.isLoading = false,
    this.error,
    this.selectedFilter,
  });

  @override
  List<Object?> get props => [isLoading, error, selectedFilter];

  NotificationsState copyWith({
    bool? isLoading,
    String? error,
    String? selectedFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
    );
  }
}
