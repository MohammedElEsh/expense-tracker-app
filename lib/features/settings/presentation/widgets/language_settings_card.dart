// Settings - Language Settings Card Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'modern_settings_card.dart';

class LanguageSettingsCard extends StatelessWidget {
  final bool isRTL;

  const LanguageSettingsCard({super.key, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsBloc>().state;

    return ModernSettingsCard(
      title: isRTL ? 'اللغة' : 'Language',
      icon: Icons.language,
      iconColor: Colors.blue,
      child: DropdownButtonFormField<String>(
        value: settings.language,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'ar', child: Text('العربية')),
        ],
        onChanged: (value) {
          if (value != null && value != settings.language) {
            context.read<SettingsBloc>().add(ChangeLanguage(value));
          }
        },
      ),
    );
  }
}
