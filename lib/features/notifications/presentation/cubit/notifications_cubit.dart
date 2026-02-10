// Notifications Feature - Cubit
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/notifications/presentation/cubit/notifications_state.dart';

/// Notifications Cubit for managing notification list filtering
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  /// Change the notification type filter
  /// Pass null to clear the filter and show all notifications
  void changeFilter(String? filter) {
    debugPrint('🔔 NotificationsCubit: Changing filter to $filter');
    if (filter == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: filter));
    }
  }
}
