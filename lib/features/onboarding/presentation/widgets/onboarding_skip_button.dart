// Onboarding - Skip Button Widget
import 'package:flutter/material.dart';

class OnboardingSkipButton extends StatelessWidget {
  final bool isRTL;
  final VoidCallback onSkip;

  const OnboardingSkipButton({
    super.key,
    required this.isRTL,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: onSkip,
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
    );
  }
}
