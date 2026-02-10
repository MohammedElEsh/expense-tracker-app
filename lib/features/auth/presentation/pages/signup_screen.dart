import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/pages/business_signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/personal_signup_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

/// شاشة الترحيب - اختيار نوع الحساب
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // App Logo & Title
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isRTL ? 'متتبع المصروفات' : 'Expense Tracker',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isRTL
                      ? 'إدارة ذكية لمصروفاتك الشخصية والتجارية'
                      : 'Smart management for your personal and business expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 60),

                // Account Type Selection
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isRTL ? 'اختر نوع الحساب' : 'Choose Account Type',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Business Account
                      _AccountTypeCard(
                        icon: Icons.business,
                        title: isRTL ? 'حساب تجاري' : 'Business Account',
                        description:
                            isRTL
                                ? 'لإدارة مصروفات شركتك وفريق العمل'
                                : 'Manage company expenses and team',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const BusinessSignupScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Personal Account
                      _AccountTypeCard(
                        icon: Icons.person,
                        title: isRTL ? 'حساب شخصي' : 'Personal Account',
                        description:
                            isRTL
                                ? 'لإدارة مصروفاتك الشخصية'
                                : 'Manage your personal expenses',
                        color: Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const PersonalSignupScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Already have account
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SimpleLoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          isRTL
                              ? 'لديك حساب؟ سجل دخول'
                              : 'Already have an account? Login',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, settings) {
                      return Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              settings.isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
