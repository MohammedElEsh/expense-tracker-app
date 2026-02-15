import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_cubit.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_state.dart';
import 'package:expense_tracker/features/companies/presentation/widgets/company_card.dart';
import 'package:expense_tracker/features/companies/presentation/widgets/company_dialog.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyCubit>().loadCompany();
  }

  Future<void> _showCompanyDialog({CompanyEntity? company}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompanyDialog(company: company),
    );

    if (result == true && mounted) {
      final isRTL = context.read<SettingsCubit>().state.language == 'ar';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            company == null
                ? (isRTL ? 'تم إنشاء الشركة بنجاح' : 'Company created successfully')
                : (isRTL ? 'تم تحديث الشركة بنجاح' : 'Company updated successfully'),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteCompany(CompanyEntity company) async {
    final isRTL = context.read<SettingsCubit>().state.language == 'ar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isRTL
              ? 'هل أنت متأكد من حذف الشركة "${company.name}"؟'
              : 'Are you sure you want to delete company "${company.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(isRTL ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(isRTL ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CompanyCubit>().deleteCompany();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'تم حذف الشركة بنجاح' : 'Company deleted successfully',
            ),
          ),
        );
      }
    }
  }

  void _navigateToDetails(CompanyEntity company) {
    context.push(AppRoutes.companyDetails, extra: company).then((_) {
      if (mounted) context.read<CompanyCubit>().loadCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return BlocConsumer<CompanyCubit, CompanyState>(
          listener: (context, state) {
            if (state is CompanyError && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Directionality(
              textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    isRTL ? 'الشركة' : 'Company',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: state is CompanyLoading
                          ? null
                          : () => context.read<CompanyCubit>().loadCompany(forceRefresh: true),
                    ),
                  ],
                ),
                body: _buildBody(context, state, isRTL),
                floatingActionButton:
                    state is CompanyLoaded && state.company == null
                        ? FloatingActionButton(
                            heroTag: 'company_add_fab',
                            onPressed: () => _showCompanyDialog(),
                            backgroundColor: AppColors.primary,
                            child: const Icon(Icons.add, color: Colors.white),
                          )
                        : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CompanyState state, bool isRTL) {
    if (state is CompanyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CompanyError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              isRTL ? 'خطأ في تحميل البيانات' : 'Error loading data',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                state.message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => context.read<CompanyCubit>().loadCompany(),
              icon: const Icon(Icons.refresh),
              label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (state is CompanyLoaded && state.company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: AppColors.textDisabledLight),
            const SizedBox(height: AppSpacing.md),
            Text(
              isRTL ? 'لا توجد شركة' : 'No Company',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isRTL ? 'قم بإنشاء شركة جديدة للبدء' : 'Create a new company to get started',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiaryLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showCompanyDialog(),
              icon: const Icon(Icons.add),
              label: Text(isRTL ? 'إنشاء شركة' : 'Create Company'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is CompanyLoaded && state.company != null) {
      final company = state.company!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: CompanyCard(
          company: company,
          isRTL: isRTL,
          onTap: () => _navigateToDetails(company),
          onEdit: () => _showCompanyDialog(company: company),
          onDelete: () => _deleteCompany(company),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
