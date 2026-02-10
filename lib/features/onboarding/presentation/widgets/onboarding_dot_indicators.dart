// Onboarding - Dot Indicators Widget
import 'package:flutter/material.dart';

class OnboardingDotIndicators extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingDotIndicators({
    super.key,
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: currentPage == index ? Colors.blue : Colors.blue[200],
          ),
        );
      }),
    );
  }
}
