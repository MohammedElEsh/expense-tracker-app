import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_cubit.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class CompanyDialog extends StatefulWidget {
  final CompanyEntity? company;

  const CompanyDialog({super.key, this.company});

  @override
  State<CompanyDialog> createState() => _CompanyDialogState();
}

class _CompanyDialogState extends State<CompanyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCurrency = 'SAR';
  final List<String> _currencies = ['SAR', 'USD', 'EUR', 'GBP', 'EGP'];

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _initializeWithCompany(widget.company!);
    } else {
      _selectedCurrency = context.read<SettingsCubit>().state.currency;
    }
  }

  void _initializeWithCompany(CompanyEntity company) {
    _nameController.text = company.name;
    _taxNumberController.text = company.taxNumber ?? '';
    _addressController.text = company.address ?? '';
    _phoneController.text = company.phone ?? '';
    _selectedCurrency = company.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxNumberController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final taxNumber = _taxNumberController.text.trim().isEmpty
        ? null
        : _taxNumberController.text.trim();
    final address = _addressController.text.trim().isEmpty
        ? null
        : _addressController.text.trim();
    final phone = _phoneController.text.trim().isEmpty
        ? null
        : _phoneController.text.trim();

    final entity = widget.company?.copyWith(
          name: name,
          taxNumber: taxNumber,
          address: address,
          phone: phone,
          currency: _selectedCurrency,
        ) ??
        CompanyEntity(
          id: '',
          name: name,
          taxNumber: taxNumber,
          address: address,
          phone: phone,
          currency: _selectedCurrency,
          fiscalYearStart: '01-01',
          isActive: true,
          employeeCount: 0,
          currentEmployeeCount: 0,
          ownerEmail: '',
          ownerId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    if (widget.company != null) {
      context.read<CompanyCubit>().updateCompany(entity);
    } else {
      context.read<CompanyCubit>().createCompany(entity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = ResponsiveUtils.getDialogWidth(context);
    final isEditing = widget.company != null;

    return BlocListener<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is CompanyError && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if ((state is CompanyLoaded) && mounted && context.canPop()) {
          context.pop(true);
        }
      },
      child: BlocBuilder<CompanyCubit, CompanyState>(
        buildWhen: (prev, curr) => curr is CompanyLoading || curr is CompanyLoaded || curr is CompanyError,
        builder: (context, state) {
          final isLoading = state is CompanyLoading;

          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              final isRTL = settings.language == 'ar';

              return WillPopScope(
                onWillPop: () async => !isLoading,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.borderRadius),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? maxWidth : 500,
                      maxHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: settings.primaryColor,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(context.borderRadius),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isEditing ? Icons.edit : Icons.add,
                                color: settings.isDarkMode ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  isEditing
                                      ? (isRTL ? 'تعديل الشركة' : 'Edit Company')
                                      : (isRTL ? 'شركة جديدة' : 'New Company'),
                                  style: AppTypography.headlineMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: settings.isDarkMode ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (context.canPop()) {
                                          context.pop();
                                        }
                                      },
                                icon: Icon(
                                  Icons.close,
                                  color: settings.isDarkMode ? Colors.black : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: isRTL ? 'اسم الشركة' : 'Company Name',
                                      hintText: isRTL ? 'أدخل اسم الشركة' : 'Enter company name',
                                      prefixIcon: const Icon(Icons.business),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return isRTL ? 'اسم الشركة مطلوب' : 'Company name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _taxNumberController,
                                    decoration: InputDecoration(
                                      labelText: isRTL ? 'الرقم الضريبي' : 'Tax Number',
                                      hintText: isRTL ? 'أدخل الرقم الضريبي (اختياري)' : 'Enter tax number (optional)',
                                      prefixIcon: const Icon(Icons.badge),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _addressController,
                                    decoration: InputDecoration(
                                      labelText: isRTL ? 'العنوان' : 'Address',
                                      hintText: isRTL ? 'أدخل عنوان الشركة (اختياري)' : 'Enter company address (optional)',
                                      prefixIcon: const Icon(Icons.location_on),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: isRTL ? 'الهاتف' : 'Phone',
                                      hintText: isRTL ? 'أدخل رقم الهاتف (اختياري)' : 'Enter phone number (optional)',
                                      prefixIcon: const Icon(Icons.phone),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    decoration: InputDecoration(
                                      labelText: isRTL ? 'العملة' : 'Currency',
                                      prefixIcon: const Icon(Icons.attach_money),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                    ),
                                    items: _currencies
                                        .map((currency) => DropdownMenuItem(
                                              value: currency,
                                              child: Text(currency),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) setState(() => _selectedCurrency = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: SizedBox(
                            width: double.infinity,
                            height: AppSpacing.buttonHeightLg,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: settings.primaryColor,
                                foregroundColor: settings.isDarkMode ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: AppSpacing.iconMd,
                                      width: AppSpacing.iconMd,
                                      child: CircularProgressIndicator(
                                        color: settings.isDarkMode ? Colors.black : Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isEditing ? Icons.check : Icons.add,
                                          color: settings.isDarkMode ? Colors.black : Colors.white,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          isEditing ? (isRTL ? 'تحديث' : 'Update') : (isRTL ? 'إضافة' : 'Add'),
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: settings.isDarkMode ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
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
}
