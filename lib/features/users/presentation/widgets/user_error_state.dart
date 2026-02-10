import 'package:flutter/material.dart';

class UserErrorState extends StatelessWidget {
  const UserErrorState({
    super.key,
    required this.error,
    required this.isRTL,
    required this.onRetry,
  });

  final String error;
  final bool isRTL;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            error,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
