import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/route_names.dart';
import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/core/storage/pref_helper.dart';
import 'package:expense_tracker/core/domain/app_context.dart';
import 'package:expense_tracker/core/domain/app_mode.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/domain/usecases/logout_usecase.dart';

/// Synchronous redirect only. Does NOT run async work.
String? redirectGuard(BuildContext context, GoRouterState state) {
  if (state.uri.path == '/' || state.uri.path.isEmpty) {
    return AppRoutes.splash;
  }
  return null;
}

/// Async auth/onboarding check. Call from splash screen; then navigate to returned route.
/// Never throws — returns a safe route (onboarding or login) on any error.
Future<String> resolveInitialRoute() async {
  try {
    final pref = getIt<PrefHelper>();

    final onboardingCompleted = await pref.isOnboardingCompleted();
    if (!onboardingCompleted) return AppRoutes.onboarding;

    final token = await pref.getAuthToken();
    if (token == null || token.isEmpty) return AppRoutes.login;

    try {
      final user = await getIt<AuthRemoteDataSource>().getCurrentUser();
      final appContext = getIt<AppContext>();
      if (user.accountType == 'business') {
        await appContext.setAppMode(AppMode.business);
        if (user.companyId != null) await appContext.setCompanyId(user.companyId);
      } else {
        await appContext.setAppMode(AppMode.personal);
        await appContext.setCompanyId(null);
      }
    } catch (_) {
      await getIt<LogoutUseCase>().call();
      return AppRoutes.login;
    }

    return AppRoutes.home;
  } catch (e, st) {
    debugPrint('⚠️ resolveInitialRoute failed: $e');
    debugPrint('$st');
    return AppRoutes.onboarding;
  }
}
