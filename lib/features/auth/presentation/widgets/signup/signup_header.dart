// Signup - Header Widget
import 'package:flutter/material.dart';

class SignupHeader extends StatelessWidget {
  final bool isRTL;
  final bool isBusinessMode;
  final Color primaryColor;

  const SignupHeader({
    super.key,
    required this.isRTL,
    required this.isBusinessMode,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          isBusinessMode ? Icons.business : Icons.person,
          size: 64,
          color: primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          isBusinessMode
              ? (isRTL
                  ? 'أنشئ حساب شركتك واحصل على صلاحيات المدير العام'
                  : 'Create your company account and get full admin access')
              : (isRTL
                  ? 'أنشئ حسابك الشخصي وابدأ في تتبع مصروفاتك'
                  : 'Create your personal account and start tracking expenses'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
