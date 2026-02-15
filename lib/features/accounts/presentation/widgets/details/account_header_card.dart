// Account Details - Header Card Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/presentation/utils/account_type_display.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class AccountHeaderCard extends StatelessWidget {
  final AccountEntity account;
  final SettingsState settings;
  final bool isRTL;
  final bool isDesktop;

  const AccountHeaderCard({
    super.key,
    required this.account,
    required this.settings,
    required this.isRTL,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            settings.primaryColor,
            settings.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: settings.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  account.type.icon,
                  size: isDesktop ? 32 : 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRTL ? 'الحساب الرئيسي' : 'Main Account',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'الرصيد الحالي' : 'Current Balance',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${account.balance.toStringAsFixed(2)} ${settings.currencySymbol}',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  account.balance >= 0
                      ? (isRTL ? 'إيجابي' : 'Positive')
                      : (isRTL ? 'سلبي' : 'Negative'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
