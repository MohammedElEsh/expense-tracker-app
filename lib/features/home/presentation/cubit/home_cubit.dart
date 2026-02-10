// Home Feature - Presentation Layer - Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/features/home/presentation/cubit/home_state.dart';
import 'package:expense_tracker/features/home/domain/usecases/logout_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final LogoutUseCase _logoutUseCase;

  HomeCubit({LogoutUseCase? logoutUseCase})
    : _logoutUseCase = logoutUseCase ?? LogoutUseCase(),
      super(HomeState(selectedDate: DateTime.now()));

  void changeViewMode(String viewMode) {
    debugPrint('🏠 تغيير وضع العرض إلى: $viewMode');
    emit(state.copyWith(viewMode: viewMode));
  }

  void changeSelectedDate(DateTime selectedDate) {
    debugPrint('📅 تغيير التاريخ المحدد إلى: $selectedDate');
    emit(state.copyWith(selectedDate: selectedDate));
  }

  void toggleSearchVisibility() {
    final newVisibility = !state.isSearchVisible;
    debugPrint('🔍 تبديل رؤية البحث: $newVisibility');
    emit(state.copyWith(isSearchVisible: newVisibility));
  }

  Future<void> logout() async {
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
