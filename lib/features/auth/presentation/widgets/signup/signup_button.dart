// Signup - Signup Button Widget
import 'package:flutter/material.dart';

class SignupButton extends StatelessWidget {
  final bool isLoading;
  final bool isRTL;
  final bool isBusinessMode;
  final VoidCallback onPressed;

  const SignupButton({
    super.key,
    required this.isLoading,
    required this.isRTL,
    required this.isBusinessMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBusinessMode ? Colors.blue : Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isLoading ? 0 : 2,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isRTL ? 'إنشاء الحساب' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
