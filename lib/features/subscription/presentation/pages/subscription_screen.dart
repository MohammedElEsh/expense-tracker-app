// ✅ Subscription Feature - Presentation Layer - Subscription Screen (Placeholder)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: settings.surfaceColor,
            appBar: AppBar(
              backgroundColor: settings.primaryColor,
              foregroundColor:
                  settings.isDarkMode ? Colors.black : Colors.white,
              elevation: 0,
              title: Text(
                isRTL ? 'الاشتراكات والخطط' : 'Subscription & Plans',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    settings.primaryColor.withValues(alpha: 0.05),
                    settings.surfaceColor,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Current Plan Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isRTL ? 'خطتك الحالية' : 'Your Current Plan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Free',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isRTL ? 'مجاني للأبد' : 'Free Forever',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Coming Soon Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: settings.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.diamond_outlined,
                            size: 64,
                            color: settings.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRTL
                                ? 'خطط متميزة قادمة!'
                                : 'Premium Plans Coming!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: settings.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isRTL
                                ? 'قريباً ستتمكن من الترقية للحصول على:'
                                : 'Soon you will be able to upgrade for:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: settings.primaryTextColor.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Plans Preview
                    _buildPlanCard(
                      context,
                      'Basic',
                      '\$4.99',
                      isRTL ? 'شهرياً' : 'per month',
                      [
                        isRTL ? '✓ مصروفات غير محدودة' : '✓ Unlimited expenses',
                        isRTL ? '✓ 5 حسابات' : '✓ 5 accounts',
                        isRTL
                            ? '✓ 10 عمليات OCR شهرياً'
                            : '✓ 10 OCR scans/month',
                        isRTL ? '✓ بدون إعلانات' : '✓ No ads',
                      ],
                      Colors.blue,
                      settings,
                    ),

                    const SizedBox(height: 16),

                    _buildPlanCard(
                      context,
                      'Premium',
                      '\$9.99',
                      isRTL ? 'شهرياً' : 'per month',
                      [
                        isRTL ? '✓ كل ميزات Basic' : '✓ All Basic features',
                        isRTL ? '✓ حسابات غير محدودة' : '✓ Unlimited accounts',
                        isRTL
                            ? '✓ 50 عملية OCR شهرياً'
                            : '✓ 50 OCR scans/month',
                        isRTL ? '✓ تصدير PDF/Excel' : '✓ Export to PDF/Excel',
                      ],
                      Colors.purple,
                      settings,
                    ),

                    const SizedBox(height: 16),

                    _buildPlanCard(
                      context,
                      'Enterprise',
                      '\$29.99',
                      isRTL ? 'شهرياً' : 'per month',
                      [
                        isRTL ? '✓ كل ميزات Premium' : '✓ All Premium features',
                        isRTL ? '✓ الوضع التجاري' : '✓ Business mode',
                        isRTL
                            ? '✓ مشاريع وموردين غير محدودة'
                            : '✓ Unlimited projects & vendors',
                        isRTL ? '✓ 50 موظف' : '✓ 50 employees',
                        isRTL ? '✓ OCR غير محدود' : '✓ Unlimited OCR',
                      ],
                      Colors.amber,
                      settings,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String name,
    String price,
    String period,
    List<String> features,
    Color color,
    SettingsState settings,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    settings.language == 'ar' ? 'قريباً' : 'Soon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: settings.primaryTextColor,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      color: settings.primaryTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  feature,
                  style: TextStyle(
                    fontSize: 14,
                    color: settings.primaryTextColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  settings.language == 'ar' ? 'اختر الخطة' : 'Choose Plan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
