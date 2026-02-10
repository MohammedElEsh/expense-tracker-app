// ✅ Settings Screen - Refactored with Widgets
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_state.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/language_settings_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/theme_settings_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/currency_settings_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/app_mode_settings_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/management_features_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/data_management_card.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/about_section_card.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';

class SettingsScreenRefactored extends StatelessWidget {
  const SettingsScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) {
        // Listen for error changes or successful operations
        final errorChanged = previous.error != current.error;
        final operationCompleted =
            previous.isLoading && !current.isLoading && current.error == null;
        return errorChanged || operationCompleted;
      },
      listener: (context, state) {
        final isRTL = state.language == 'ar';

        // Show error messages
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: isRTL ? 'إغلاق' : 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
        // Success messages are handled in individual widgets (e.g., DataManagementCard)
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final isRTL = settings.language == 'ar';
              final currentUser = userState.currentUser;
              final isDesktop = context.isDesktop;

              return Directionality(
                textDirection:
                    isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                child: Scaffold(
                  backgroundColor: settings.surfaceColor,
                  appBar: AppBar(
                    backgroundColor: settings.primaryColor,
                    foregroundColor:
                        settings.isDarkMode ? Colors.black : Colors.white,
                    elevation: 0,
                    title: Text(
                      isRTL ? 'الإعدادات' : 'Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 24 : 20,
                      ),
                    ),
                  ),
                  body:
                      settings.isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    settings.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isRTL ? 'جاري التحميل...' : 'Loading...',
                                  style: TextStyle(
                                    color: settings.primaryTextColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Container(
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
                              padding: EdgeInsets.all(isDesktop ? 32 : 16),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isDesktop ? 800 : double.infinity,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // General Settings Section
                                    _buildSectionHeader(
                                      isRTL
                                          ? 'الإعدادات العامة'
                                          : 'General Settings',
                                      Icons.settings,
                                      settings,
                                    ),
                                    const SizedBox(height: 16),

                                    // Language
                                    LanguageSettingsCard(isRTL: isRTL),
                                    const SizedBox(height: 16),

                                    // Theme
                                    ThemeSettingsCard(isRTL: isRTL),
                                    const SizedBox(height: 16),

                                    // Currency
                                    CurrencySettingsCard(isRTL: isRTL),
                                    const SizedBox(height: 16),

                                    // App Mode
                                    AppModeSettingsCard(
                                      settings: settings,
                                      isRTL: isRTL,
                                    ),

                                    const SizedBox(height: 32),

                                    // Management Features Section
                                    _buildSectionHeader(
                                      isRTL
                                          ? 'ميزات الإدارة'
                                          : 'Management Features',
                                      Icons.admin_panel_settings,
                                      settings,
                                    ),
                                    const SizedBox(height: 16),

                                    ManagementFeaturesCard(
                                      settings: settings,
                                      currentUser: currentUser,
                                      isRTL: isRTL,
                                    ),

                                    const SizedBox(height: 32),

                                    // Data Management Section
                                    _buildSectionHeader(
                                      isRTL
                                          ? 'إدارة البيانات'
                                          : 'Data Management',
                                      Icons.storage,
                                      settings,
                                    ),
                                    const SizedBox(height: 16),

                                    DataManagementCard(
                                      settings: settings,
                                      isRTL: isRTL,
                                    ),

                                    const SizedBox(height: 32),

                                    // About Section
                                    _buildSectionHeader(
                                      isRTL ? 'حول التطبيق' : 'About',
                                      Icons.info_outline,
                                      settings,
                                    ),
                                    const SizedBox(height: 16),

                                    AboutSectionCard(
                                      settings: settings,
                                      isRTL: isRTL,
                                    ),

                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    SettingsState settings,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: settings.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
