// ✅ Clean Architecture - Companies Screen
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/companies/presentation/widgets/company_card.dart';
import 'package:expense_tracker/features/companies/presentation/widgets/company_dialog.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';
import 'package:expense_tracker/features/companies/presentation/pages/company_details_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  // API Service
  CompanyApiService get _companyService => serviceLocator.companyService;

  Company? _company;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final company = await _companyService.getMyCompany(forceRefresh: true);

      setState(() {
        _company = company;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCompanyDialog({Company? company}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CompanyDialog(company: company),
    );

    if (result == true) {
      await _loadCompany();

      if (mounted) {
        final isRTL = context.read<SettingsBloc>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              company == null
                  ? (isRTL ? 'تم إنشاء الشركة بنجاح' : 'Company created successfully')
                  : (isRTL ? 'تم تحديث الشركة بنجاح' : 'Company updated successfully'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteCompany() async {
    final isRTL = context.read<SettingsBloc>().state.language == 'ar';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          isRTL
              ? 'هل أنت متأكد من حذف الشركة "${_company?.name}"؟'
              : 'Are you sure you want to delete company "${_company?.name}"?',
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
        await _loadCompany();
        if (mounted) {
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

  void _navigateToCompanyDetails(Company company) {
    Navigator.push(
      context,
      AnimatedPageRoute(child: CompanyDetailsScreen(company: company)),
    ).then((_) => _loadCompany());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isRTL ? 'الشركة' : 'Company',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadCompany,
                ),
              ],
            ),
            body: _buildBody(isRTL),
            floatingActionButton: _company == null
                ? FloatingActionButton(
                    heroTag: 'company_add_fab',
                    onPressed: () => _showCompanyDialog(),
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isRTL) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'خطأ في تحميل البيانات' : 'Error loading data',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCompany,
              icon: const Icon(Icons.refresh),
              label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا توجد شركة' : 'No Company',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isRTL
                  ? 'قم بإنشاء شركة جديدة للبدء'
                  : 'Create a new company to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCompanyDialog(),
              icon: const Icon(Icons.add),
              label: Text(isRTL ? 'إنشاء شركة' : 'Create Company'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CompanyCard(
        company: _company!,
        isRTL: isRTL,
        onTap: () => _navigateToCompanyDetails(_company!),
        onEdit: () => _showCompanyDialog(company: _company),
        onDelete: _deleteCompany,
      ),
    );
  }
}

