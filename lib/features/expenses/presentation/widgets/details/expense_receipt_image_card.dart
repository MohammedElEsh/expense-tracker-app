// Expense Details - Receipt Image Card Widget
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class ExpenseReceiptImageCard extends StatelessWidget {
  final Expense expense;
  final bool isRTL;
  final VoidCallback onViewFullImage;

  const ExpenseReceiptImageCard({
    super.key,
    required this.expense,
    required this.isRTL,
    required this.onViewFullImage,
  });

  @override
  Widget build(BuildContext context) {
    if (expense.photoPath == null) return const SizedBox.shrink();

    return _buildCard(
      context,
      title: isRTL ? 'الإيصال' : 'Receipt',
      icon: Icons.image,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(expense.photoPath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRTL ? 'لم يتم العثور على الصورة' : 'Image not found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onViewFullImage,
                icon: const Icon(Icons.fullscreen),
                label: Text(isRTL ? 'عرض كامل' : 'View Full'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
