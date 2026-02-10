// Settings - Data Management Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart';
import 'modern_settings_card.dart';

class DataManagementCard extends StatelessWidget {
  final SettingsState settings;
  final bool isRTL;

  const DataManagementCard({
    super.key,
    required this.settings,
    required this.isRTL,
  });

  Future<void> _handleClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'تأكيد المسح' : 'Confirm Clear'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء!'
                  : 'Are you sure you want to clear all data? This action cannot be undone!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRTL ? 'مسح' : 'Clear'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ExpenseCubit>().loadExpenses();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'تم مسح البيانات بنجاح' : 'Data cleared successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = context.watch<ExpenseCubit>().state;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) {
        // Listen for successful reset completion (was loading, now not loading, no error)
        return previous.isLoading &&
            !current.isLoading &&
            current.error == null &&
            previous.error == null;
      },
      listener: (context, state) {
        // Show success message for reset
        final isRTL = state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL
                  ? 'تم إعادة تعيين الإعدادات بنجاح'
                  : 'Settings reset successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: ModernSettingsCard(
        title: isRTL ? 'إدارة البيانات' : 'Data Management',
        icon: Icons.storage,
        iconColor: Colors.red,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'المصروفات المحفوظة' : 'Stored Expenses',
                        style: TextStyle(
                          fontSize: 12,
                          color: settings.secondaryTextColor,
                        ),
                      ),
                      Text(
                        '${expenseState.allExpenses.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.receipt_long,
                    size: 40,
                    color: Colors.blue.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reset Settings Button
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final isLoading = state.isLoading;
                  return ElevatedButton.icon(
                    onPressed:
                        isLoading ? null : () => _handleResetSettings(context),
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.restore),
                    label: Text(
                      isLoading
                          ? (isRTL ? 'جاري إعادة التعيين...' : 'Resetting...')
                          : (isRTL
                              ? 'إعادة تعيين الإعدادات'
                              : 'Reset Settings'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.orange.withValues(
                        alpha: 0.6,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Clear Data Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleClearData(context),
                icon: const Icon(Icons.delete_forever),
                label: Text(isRTL ? 'مسح جميع البيانات' : 'Clear All Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetSettings(BuildContext context) async {
    final isRTL = settings.language == 'ar';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'إعادة تعيين الإعدادات' : 'Reset Settings'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟'
                  : 'Are you sure you want to reset all settings to default values?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: Text(isRTL ? 'إعادة تعيين' : 'Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      // Dispatch ResetSettings event
      context.read<SettingsCubit>().resetSettings();
    }
  }
}
