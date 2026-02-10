// Onboarding - Navigation Buttons Widget
import 'package:flutter/material.dart';

class OnboardingNavigationButtons extends StatelessWidget {
  final int currentPage;
  final int lastPageIndex;
  final bool isRTL;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const OnboardingNavigationButtons({
    super.key,
    required this.currentPage,
    required this.lastPageIndex,
    required this.isRTL,
    required this.onPrevious,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue[300]!),
                ),
                child: Text(
                  isRTL ? 'السابق' : 'Previous',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ),

          if (currentPage > 0) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: currentPage == lastPageIndex ? onGetStarted : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: Text(
                currentPage == lastPageIndex
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
    );
  }
}
