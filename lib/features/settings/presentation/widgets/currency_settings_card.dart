// Settings - Currency Settings Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'modern_settings_card.dart';

class CurrencySettingsCard extends StatelessWidget {
  final bool isRTL;

  const CurrencySettingsCard({super.key, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) {
        // Listen for successful currency update
        return previous.currency != current.currency &&
            !current.isLoading &&
            current.error == null &&
            previous.isLoading;
      },
      listener: (context, state) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'تم تحديث العملة بنجاح' : 'Currency updated successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: ModernSettingsCard(
        title: isRTL ? 'العملة' : 'Currency',
        icon: Icons.attach_money,
        iconColor: Colors.green,
        child: DropdownButtonFormField<String>(
          value: settings.currency,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon:
                settings.isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : null,
          ),
          items:
              SettingsService.availableCurrencies.map((currencyCode) {
                final symbol = SettingsService.getCurrencySymbol(currencyCode);
                return DropdownMenuItem(
                  value: currencyCode,
                  child: Text('$currencyCode ($symbol)'),
                );
              }).toList(),
          onChanged:
              settings.isLoading
                  ? null
                  : (value) {
                    if (value != null && value != settings.currency) {
                      context.read<SettingsCubit>().changeCurrency(value);
                    }
                  },
        ),
      ),
    );
  }
}
