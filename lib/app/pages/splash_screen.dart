import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/route_guards.dart';
import 'package:expense_tracker/app/router/route_names.dart';

/// Minimal resolver screen. Checks auth/onboarding and navigates to home, login, or onboarding.
/// No visible splash UI — resolves and navigates immediately.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAndNavigate());
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      debugPrint('⚠️ Splash timeout — forcing navigation to onboarding');
      _navigateTo(AppRoutes.onboarding);
    });
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    try {
      context.go(route);
    } catch (e) {
      debugPrint('⚠️ go(route) failed: $e');
    }
  }

  Future<void> _resolveAndNavigate() async {
    String route = AppRoutes.onboarding;
    try {
      route = await resolveInitialRoute().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⚠️ resolveInitialRoute timeout');
          return AppRoutes.onboarding;
        },
      );
    } catch (e, st) {
      debugPrint('⚠️ resolveInitialRoute error: $e');
      debugPrint('$st');
      route = AppRoutes.onboarding;
    }
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    if (!mounted) return;
    _navigateTo(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
