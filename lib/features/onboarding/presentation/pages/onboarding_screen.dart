import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_service.dart';
import 'package:expense_tracker/app/pages/main_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_page_content.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_dot_indicators.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_navigation_buttons.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_skip_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const int _pageCount = 4;
  static const int _lastPageIndex = _pageCount - 1;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.blue[50],
            body: SafeArea(
              child: Column(
                children: [
                  // Skip button
                  OnboardingSkipButton(
                    isRTL: isRTL,
                    onSkip: _completeOnboarding,
                  ),

                  // Page view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        _restartAnimations();
                      },
                      children: _buildPages(isRTL),
                    ),
                  ),

                  // Page indicators
                  OnboardingDotIndicators(
                    currentPage: _currentPage,
                    pageCount: _pageCount,
                  ),

                  const SizedBox(height: 24),

                  // Navigation buttons
                  OnboardingNavigationButtons(
                    currentPage: _currentPage,
                    lastPageIndex: _lastPageIndex,
                    isRTL: isRTL,
                    onPrevious: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onNext: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onGetStarted: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPages(bool isRTL) {
    return [
      OnboardingPageContent(
        icon: Icons.account_balance_wallet,
        title: isRTL ? 'مرحباً بك في Spendly' : 'Welcome to Spendly',
        subtitle:
            isRTL
                ? 'تطبيقك الذكي لإدارة المصروفات الشخصية'
                : 'Your smart personal expense management app',
        description:
            isRTL
                ? 'تتبع مصروفاتك بسهولة واحصل على تحليلات مفصلة لعاداتك المالية'
                : 'Track your expenses easily and get detailed insights into your spending habits',
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      OnboardingPageContent(
        icon: Icons.add_circle,
        title: isRTL ? 'إضافة سريعة' : 'Quick Add',
        subtitle:
            isRTL ? 'أضف مصروفاتك في ثوانٍ' : 'Add your expenses in seconds',
        description:
            isRTL
                ? 'واجهة بسيطة وسريعة لتسجيل مصروفاتك اليومية مع تصنيفات ذكية'
                : 'Simple and fast interface to record your daily expenses with smart categories',
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      OnboardingPageContent(
        icon: Icons.bar_chart,
        title: isRTL ? 'تحليلات متقدمة' : 'Advanced Analytics',
        subtitle:
            isRTL ? 'اطلع على إحصائيات مفصلة' : 'View detailed statistics',
        description:
            isRTL
                ? 'مخططات بيانية وتقارير شاملة لفهم أنماط إنفاقك وتحسين ميزانيتك'
                : 'Charts and comprehensive reports to understand your spending patterns and improve your budget',
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
      OnboardingPageContent(
        icon: Icons.savings,
        title: isRTL ? 'إدارة الميزانية' : 'Budget Management',
        subtitle:
            isRTL
                ? 'حدد ميزانياتك واتبع تقدمك'
                : 'Set budgets and track your progress',
        description:
            isRTL
                ? 'تعيين حدود للإنفاق مع تنبيهات ذكية عند اقتراب انتهاء الميزانية'
                : 'Set spending limits with smart alerts when approaching budget limits',
        fadeAnimation: _fadeAnimation,
        slideAnimation: _slideAnimation,
      ),
    ];
  }

  void _restartAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }
}
