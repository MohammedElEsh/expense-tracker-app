import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_service.dart';
import 'package:expense_tracker/utils/theme_helper.dart';
import 'package:expense_tracker/screens/main_screen.dart';

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
    return BlocBuilder<SettingsBloc, SettingsState>(
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
                  Align(
                    alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          isRTL ? 'تخطي' : 'Skip',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        _restartAnimations();
                      },
                      children: [
                        _buildPage(
                          icon: Icons.account_balance_wallet,
                          title:
                              isRTL
                                  ? 'مرحباً بك في Spendly'
                                  : 'Welcome to Spendly',
                          subtitle:
                              isRTL
                                  ? 'تطبيقك الذكي لإدارة المصروفات الشخصية'
                                  : 'Your smart personal expense management app',
                          description:
                              isRTL
                                  ? 'تتبع مصروفاتك بسهولة واحصل على تحليلات مفصلة لعاداتك المالية'
                                  : 'Track your expenses easily and get detailed insights into your spending habits',
                          isRTL: isRTL,
                        ),
                        _buildPage(
                          icon: Icons.add_circle,
                          title: isRTL ? 'إضافة سريعة' : 'Quick Add',
                          subtitle:
                              isRTL
                                  ? 'أضف مصروفاتك في ثوانٍ'
                                  : 'Add your expenses in seconds',
                          description:
                              isRTL
                                  ? 'واجهة بسيطة وسريعة لتسجيل مصروفاتك اليومية مع تصنيفات ذكية'
                                  : 'Simple and fast interface to record your daily expenses with smart categories',
                          isRTL: isRTL,
                        ),
                        _buildPage(
                          icon: Icons.bar_chart,
                          title:
                              isRTL ? 'تحليلات متقدمة' : 'Advanced Analytics',
                          subtitle:
                              isRTL
                                  ? 'اطلع على إحصائيات مفصلة'
                                  : 'View detailed statistics',
                          description:
                              isRTL
                                  ? 'مخططات بيانية وتقارير شاملة لفهم أنماط إنفاقك وتحسين ميزانيتك'
                                  : 'Charts and comprehensive reports to understand your spending patterns and improve your budget',
                          isRTL: isRTL,
                        ),
                        _buildPage(
                          icon: Icons.savings,
                          title:
                              isRTL ? 'إدارة الميزانية' : 'Budget Management',
                          subtitle:
                              isRTL
                                  ? 'حدد ميزانياتك واتبع تقدمك'
                                  : 'Set budgets and track your progress',
                          description:
                              isRTL
                                  ? 'تعيين حدود للإنفاق مع تنبيهات ذكية عند اقتراب انتهاء الميزانية'
                                  : 'Set spending limits with smart alerts when approaching budget limits',
                          isRTL: isRTL,
                        ),
                      ],
                    ),
                  ),

                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _currentPage == index
                                  ? Colors.blue
                                  : Colors.blue[200],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.blue[300]!),
                              ),
                              child: Text(
                                isRTL ? 'السابق' : 'Previous',
                                style: TextStyle(color: Colors.blue[700]),
                              ),
                            ),
                          ),

                        if (_currentPage > 0) const SizedBox(width: 16),

                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _currentPage == 3
                                    ? _completeOnboarding
                                    : () {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: Text(
                              _currentPage == 3
                                  ? (isRTL ? 'ابدأ الآن' : 'Get Started')
                                  : (isRTL ? 'التالي' : 'Next'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isRTL,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 60, color: Colors.white),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
