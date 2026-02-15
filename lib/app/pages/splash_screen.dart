import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/route_guards.dart';
import 'package:expense_tracker/app/router/route_names.dart';

/// Shows app logo until async auth resolves, then navigates to onboarding, login, or home.
/// Includes timeout and safety timer so the app never stays stuck on logo.
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
    // Safety: if still on splash after 6 seconds, force go to onboarding
    Future<void>.delayed(const Duration(seconds: 6), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      debugPrint('⚠️ Splash timeout — forcing navigation to onboarding');
      _navigateTo(AppRoutes.onboarding);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAndNavigate());
  }

  void _navigateTo(String route) {
    if (!mounted) return;
    try {
      GoRouter.of(context).go(route);
    } catch (e) {
      debugPrint('⚠️ go(route) failed: $e');
    }
  }

  Future<void> _resolveAndNavigate() async {
    String route = AppRoutes.onboarding;
    try {
      route = await resolveInitialRoute().timeout(
        const Duration(seconds: 5),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigateTo(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Spendly',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
