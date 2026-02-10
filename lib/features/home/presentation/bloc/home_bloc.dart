// Home Feature - Presentation Layer - BLoC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../domain/usecases/logout_usecase.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LogoutUseCase _logoutUseCase;

  HomeBloc({LogoutUseCase? logoutUseCase})
    : _logoutUseCase = logoutUseCase ?? LogoutUseCase(),
      super(HomeState(selectedDate: DateTime.now())) {
    on<ChangeViewModeEvent>(_onChangeViewMode);
    on<ChangeSelectedDateEvent>(_onChangeSelectedDate);
    on<ToggleSearchVisibilityEvent>(_onToggleSearchVisibility);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  void _onChangeViewMode(ChangeViewModeEvent event, Emitter<HomeState> emit) {
    debugPrint('🏠 تغيير وضع العرض إلى: ${event.viewMode}');
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onChangeSelectedDate(
    ChangeSelectedDateEvent event,
    Emitter<HomeState> emit,
  ) {
    debugPrint('📅 تغيير التاريخ المحدد إلى: ${event.selectedDate}');
    emit(state.copyWith(selectedDate: event.selectedDate));
  }

  void _onToggleSearchVisibility(
    ToggleSearchVisibilityEvent event,
    Emitter<HomeState> emit,
  ) {
    final newVisibility = !state.isSearchVisible;
    debugPrint('🔍 تبديل رؤية البحث: $newVisibility');
    emit(state.copyWith(isSearchVisible: newVisibility));
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      debugPrint('🚪 بدء عملية تسجيل الخروج...');
      emit(state.copyWith(isLoggingOut: true));

      await _logoutUseCase.call();

      debugPrint('✅ تم تسجيل الخروج بنجاح');
      // لا نحتاج emit هنا لأن التطبيق سينتقل لشاشة تسجيل الدخول
    } catch (error) {
      debugPrint('❌ خطأ في تسجيل الخروج: $error');
      emit(state.copyWith(isLoggingOut: false, logoutError: error.toString()));
    }
  }
}
