// ✅ Company Dialog - Create/Edit
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';

class CompanyDialog extends StatefulWidget {
  final Company? company;

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

  // API Service
  CompanyApiService get _companyService => serviceLocator.companyService;

  String _selectedCurrency = 'SAR';
  bool _isLoading = false;

  // Available currencies
  final List<String> _currencies = ['SAR', 'USD', 'EUR', 'GBP', 'EGP'];

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _initializeWithCompany(widget.company!);
    } else {
      // Get default currency from settings
      final settings = context.read<SettingsCubit>().state;
      _selectedCurrency = settings.currency;
    }
  }

  void _initializeWithCompany(Company company) {
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final company =
          widget.company?.copyWith(
            name: _nameController.text.trim(),
            taxNumber:
                _taxNumberController.text.trim().isEmpty
                    ? null
                    : _taxNumberController.text.trim(),
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            phone:
                _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
            currency: _selectedCurrency,
          ) ??
          Company(
            id: '', // Will be set by API
            name: _nameController.text.trim(),
            taxNumber:
                _taxNumberController.text.trim().isEmpty
                    ? null
                    : _taxNumberController.text.trim(),
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            phone:
                _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
            currency: _selectedCurrency,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            ownerEmail: '', // Will be set by API
          );

      // Save or update company via API
      if (widget.company != null) {
        await _companyService.updateCompany(company);
      } else {
        await _companyService.createCompany(company);
      }

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsCubit>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRTL ? 'خطأ: $e' : 'Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = ResponsiveUtils.getDialogWidth(context);
    final isEditing = widget.company != null;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => !_isLoading,
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
                  // Header
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
                          color:
                              settings.isDarkMode ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            isEditing
                                ? (isRTL ? 'تعديل الشركة' : 'Edit Company')
                                : (isRTL ? 'شركة جديدة' : 'New Company'),
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  settings.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                          icon: Icon(
                            Icons.close,
                            color:
                                settings.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company Name
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText:
                                    isRTL ? 'اسم الشركة' : 'Company Name',
                                hintText:
                                    isRTL
                                        ? 'أدخل اسم الشركة'
                                        : 'Enter company name',
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return isRTL
                                      ? 'اسم الشركة مطلوب'
                                      : 'Company name is required';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Tax Number
                            TextFormField(
                              controller: _taxNumberController,
                              decoration: InputDecoration(
                                labelText:
                                    isRTL ? 'الرقم الضريبي' : 'Tax Number',
                                hintText:
                                    isRTL
                                        ? 'أدخل الرقم الضريبي (اختياري)'
                                        : 'Enter tax number (optional)',
                                prefixIcon: const Icon(Icons.badge),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Address
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: isRTL ? 'العنوان' : 'Address',
                                hintText:
                                    isRTL
                                        ? 'أدخل عنوان الشركة (اختياري)'
                                        : 'Enter company address (optional)',
                                prefixIcon: const Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              maxLines: 2,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: isRTL ? 'الهاتف' : 'Phone',
                                hintText:
                                    isRTL
                                        ? 'أدخل رقم الهاتف (اختياري)'
                                        : 'Enter phone number (optional)',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            // Currency
                            DropdownButtonFormField<String>(
                              value: _selectedCurrency,
                              decoration: InputDecoration(
                                labelText: isRTL ? 'العملة' : 'Currency',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                              ),
                              items:
                                  _currencies.map((currency) {
                                    return DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCurrency = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonHeightLg,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settings.primaryColor,
                          foregroundColor:
                              settings.isDarkMode ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: AppSpacing.iconMd,
                                  width: AppSpacing.iconMd,
                                  child: CircularProgressIndicator(
                                    color:
                                        settings.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing ? Icons.check : Icons.add,
                                      color:
                                          settings.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      isEditing
                                          ? (isRTL ? 'تحديث' : 'Update')
                                          : (isRTL ? 'إضافة' : 'Add'),
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            settings.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
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
  }
}
