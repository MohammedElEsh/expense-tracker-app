// Login - Header Widget (Logo + Title)
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final bool isRTL;

  const LoginHeader({super.key, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
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
          isRTL ? 'سجل دخولك للمتابعة' : 'Login to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
