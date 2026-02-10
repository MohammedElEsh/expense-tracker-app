// Onboarding Feature - Cubit
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/cubit/onboarding_state.dart';

/// Onboarding Cubit for managing onboarding page navigation
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  /// Change the current onboarding page
  void changePage(int page) {
    debugPrint('📖 OnboardingCubit: Changing page to $page');
    emit(state.copyWith(currentPage: page));
  }

  /// Mark onboarding as completed
  void completeOnboarding() {
    debugPrint('✅ OnboardingCubit: Onboarding completed');
    emit(state.copyWith(isCompleted: true));
  }
}
