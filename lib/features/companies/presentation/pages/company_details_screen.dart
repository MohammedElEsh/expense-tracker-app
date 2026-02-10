// ✅ Clean Architecture - Company Details Screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/companies/presentation/widgets/company_dialog.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/core/utils/theme_helper.dart';
import 'package:intl/intl.dart';

class CompanyDetailsScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailsScreen({super.key, required this.company});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  // Current company (can be updated after edit)
  late Company _currentCompany;
  bool _isLoading = false;

  // API Service
  CompanyApiService get _companyService => serviceLocator.companyService;

  @override
  void initState() {
    super.initState();
    _currentCompany = widget.company;
  }

  Future<void> _refreshCompany() async {
    setState(() => _isLoading = true);
    try {
      final company = await _companyService.getMyCompany(forceRefresh: true);
      if (company != null && mounted) {
        setState(() {
          _currentCompany = company;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsCubit>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'خطأ في تحديث البيانات: $e' : 'Error refreshing data: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editCompany() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompanyDialog(company: _currentCompany),
    );

    if (result == true) {
      await _refreshCompany();
      if (mounted) {
        final isRTL = context.read<SettingsCubit>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'تم تحديث الشركة بنجاح' : 'Company updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteCompany() async {
    final isRTL = context.read<SettingsCubit>().state.language == 'ar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'تأكيد الحذف' : 'Confirm Delete'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من حذف الشركة "${_currentCompany.name}"؟'
                  : 'Are you sure you want to delete company "${_currentCompany.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(isRTL ? 'حذف' : 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _companyService.deleteCompany();
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'تم حذف الشركة بنجاح' : 'Company deleted successfully',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isRTL ? 'خطأ في حذف الشركة: $e' : 'Error deleting company: $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final isDesktop = context.isDesktop;

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
                isRTL ? 'تفاصيل الشركة' : 'Company Details',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshCompany,
                    tooltip: isRTL ? 'تحديث' : 'Refresh',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editCompany,
                  tooltip: isRTL ? 'تعديل' : 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteCompany,
                  tooltip: isRTL ? 'حذف' : 'Delete',
                ),
              ],
            ),
            body:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 24 : 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderCard(settings, isRTL),
                            const SizedBox(height: 16),
                            _buildInfoCard(settings, isRTL),
                            const SizedBox(height: 16),
                            _buildOwnerCard(settings, isRTL),
                            const SizedBox(height: 16),
                            _buildStatsCard(settings, isRTL),
                          ],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(SettingsState settings, bool isRTL) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              settings.primaryColor,
              settings.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
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
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCompany.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _currentCompany.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentCompany.isActive
                                  ? (isRTL ? 'نشط' : 'Active')
                                  : (isRTL ? 'غير نشط' : 'Inactive'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(SettingsState settings, bool isRTL) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? 'معلومات الشركة' : 'Company Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: settings.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.attach_money,
              isRTL ? 'العملة' : 'Currency',
              _currentCompany.currency,
              settings,
            ),
            if (_currentCompany.taxNumber != null &&
                _currentCompany.taxNumber!.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.badge,
                isRTL ? 'الرقم الضريبي' : 'Tax Number',
                _currentCompany.taxNumber!,
                settings,
              ),
            if (_currentCompany.phone != null &&
                _currentCompany.phone!.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.phone,
                isRTL ? 'الهاتف' : 'Phone',
                _currentCompany.phone!,
                settings,
              ),
            if (_currentCompany.address != null &&
                _currentCompany.address!.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.location_on,
                isRTL ? 'العنوان' : 'Address',
                _currentCompany.address!,
                settings,
              ),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              isRTL ? 'بداية السنة المالية' : 'Fiscal Year Start',
              _currentCompany.fiscalYearStart,
              settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard(SettingsState settings, bool isRTL) {
    if (_currentCompany.ownerId == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? 'المالك' : 'Owner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: settings.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: settings.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: settings.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentCompany.ownerId!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: settings.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentCompany.ownerId!.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: settings.secondaryTextColor,
                        ),
                      ),
                      if (_currentCompany.ownerId!.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _currentCompany.ownerId!.phone!,
                          style: TextStyle(
                            fontSize: 14,
                            color: settings.secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(SettingsState settings, bool isRTL) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? 'الإحصائيات' : 'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: settings.primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.people,
                    isRTL ? 'الموظفين' : 'Employees',
                    '${_currentCompany.currentEmployeeCount}',
                    settings,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.calendar_today,
                    isRTL ? 'تاريخ الإنشاء' : 'Created',
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(_currentCompany.createdAt),
                    settings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    SettingsState settings,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.tertiaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: settings.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    SettingsState settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: settings.primaryColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.tertiaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: settings.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
