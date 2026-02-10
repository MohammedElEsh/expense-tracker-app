// Home Feature - Presentation Layer - BLoC Events
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// تغيير وضع العرض (day, week, month, all)
class ChangeViewModeEvent extends HomeEvent {
  final String viewMode;

  const ChangeViewModeEvent(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

// تغيير التاريخ المحدد
class ChangeSelectedDateEvent extends HomeEvent {
  final DateTime selectedDate;

  const ChangeSelectedDateEvent(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

// تبديل رؤية البحث
class ToggleSearchVisibilityEvent extends HomeEvent {
  const ToggleSearchVisibilityEvent();
}

// تسجيل الخروج
class LogoutRequestedEvent extends HomeEvent {
  const LogoutRequestedEvent();
}
