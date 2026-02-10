// Add Expense - Save Button Widget
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isRTL;
  final bool isEditMode;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.isLoading,
    required this.isRTL,
    required this.isEditMode,
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
          backgroundColor: Theme.of(context).primaryColor,
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
                    Icon(
                      isEditMode ? Icons.check : Icons.add,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditMode
                          ? (isRTL ? 'تحديث' : 'Update')
                          : (isRTL ? 'إضافة' : 'Add'),
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
