// ✅ Vendor Dialog - Modern, Clean UI with Full Form Support
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class VendorDialogRefactored extends StatefulWidget {
  final Vendor? vendor;

  const VendorDialogRefactored({super.key, this.vendor});

  @override
  State<VendorDialogRefactored> createState() => _VendorDialogRefactoredState();
}

class _VendorDialogRefactoredState extends State<VendorDialogRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _commercialRegController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _notesController = TextEditingController();

  VendorType _selectedType = VendorType.supplier;
  VendorStatus _selectedStatus = VendorStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.vendor != null) {
      _initializeWithVendor(widget.vendor!);
    }
  }

  void _initializeWithVendor(Vendor vendor) {
    _nameController.text = vendor.name;
    _companyNameController.text = vendor.companyName ?? '';
    _emailController.text = vendor.email ?? '';
    _phoneController.text = vendor.phone ?? '';
    _addressController.text = vendor.address ?? '';
    _taxNumberController.text = vendor.taxNumber ?? '';
    _commercialRegController.text = vendor.commercialRegistration ?? '';
    _contactPersonController.text = vendor.contactPerson ?? '';
    _bankAccountController.text = vendor.bankAccount ?? '';
    _notesController.text = vendor.notes ?? '';
    _selectedType = vendor.type;
    _selectedStatus = vendor.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _commercialRegController.dispose();
    _contactPersonController.dispose();
    _bankAccountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVendor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vendor =
          widget.vendor?.copyWith(
            name: _nameController.text.trim(),
            companyName:
                _companyNameController.text.trim().isEmpty
                    ? null
                    : _companyNameController.text.trim(),
            email:
                _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
            phone:
                _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            taxNumber:
                _taxNumberController.text.trim().isEmpty
                    ? null
                    : _taxNumberController.text.trim(),
            commercialRegistration:
                _commercialRegController.text.trim().isEmpty
                    ? null
                    : _commercialRegController.text.trim(),
            contactPerson:
                _contactPersonController.text.trim().isEmpty
                    ? null
                    : _contactPersonController.text.trim(),
            bankAccount:
                _bankAccountController.text.trim().isEmpty
                    ? null
                    : _bankAccountController.text.trim(),
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
            type: _selectedType,
            status: _selectedStatus,
          ) ??
          Vendor(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            companyName:
                _companyNameController.text.trim().isEmpty
                    ? null
                    : _companyNameController.text.trim(),
            email:
                _emailController.text.trim().isEmpty
                    ? null
                    : _emailController.text.trim(),
            phone:
                _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            taxNumber:
                _taxNumberController.text.trim().isEmpty
                    ? null
                    : _taxNumberController.text.trim(),
            commercialRegistration:
                _commercialRegController.text.trim().isEmpty
                    ? null
                    : _commercialRegController.text.trim(),
            contactPerson:
                _contactPersonController.text.trim().isEmpty
                    ? null
                    : _contactPersonController.text.trim(),
            bankAccount:
                _bankAccountController.text.trim().isEmpty
                    ? null
                    : _bankAccountController.text.trim(),
            notes:
                _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
            type: _selectedType,
            status: _selectedStatus,
            createdAt: DateTime.now(),
          );

      final vendorService = serviceLocator.vendorService;
      if (widget.vendor != null) {
        await vendorService.updateVendor(vendor);
      } else {
        await vendorService.createVendor(vendor);
      }

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsBloc>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRTL ? 'خطأ: $e' : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = ResponsiveUtils.getDialogWidth(context);
    final isEditing = widget.vendor != null;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';
        final theme = Theme.of(context);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? maxWidth : 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(context, settings, isRTL, isEditing),

                  // Form Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          _buildSectionTitle(
                            context,
                            isRTL ? 'المعلومات الأساسية' : 'Basic Information',
                            Icons.info_outline,
                            theme,
                          ),
                          const SizedBox(height: 16),

                          _buildVendorNameField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildCompanyNameField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTypeDropdown(
                                  context,
                                  isRTL,
                                  theme,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatusDropdown(
                                  context,
                                  isRTL,
                                  theme,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Contact Information Section
                          _buildSectionTitle(
                            context,
                            isRTL ? 'معلومات الاتصال' : 'Contact Information',
                            Icons.contact_mail_outlined,
                            theme,
                          ),
                          const SizedBox(height: 16),

                          _buildEmailField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildPhoneField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildContactPersonField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildAddressField(context, isRTL, theme),

                          const SizedBox(height: 32),

                          // Business Information Section
                          _buildSectionTitle(
                            context,
                            isRTL
                                ? 'المعلومات التجارية'
                                : 'Business Information',
                            Icons.business_outlined,
                            theme,
                          ),
                          const SizedBox(height: 16),

                          _buildTaxNumberField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildCommercialRegField(context, isRTL, theme),
                          const SizedBox(height: 16),

                          _buildBankAccountField(context, isRTL, theme),

                          const SizedBox(height: 32),

                          // Additional Notes Section
                          _buildSectionTitle(
                            context,
                            isRTL ? 'ملاحظات إضافية' : 'Additional Notes',
                            Icons.note_outlined,
                            theme,
                          ),
                          const SizedBox(height: 16),

                          _buildNotesField(context, isRTL, theme),
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  _buildActionButtons(context, settings, isRTL, isEditing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
    bool isEditing,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: settings.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (settings.isDarkMode ? Colors.black : Colors.white)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEditing ? Icons.edit_outlined : Icons.add_business_outlined,
              color: settings.isDarkMode ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isEditing
                  ? (isRTL ? 'تعديل المورد' : 'Edit Vendor')
                  : (isRTL ? 'مورد جديد' : 'New Vendor'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: settings.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: settings.isDarkMode ? Colors.black : Colors.white,
            ),
            tooltip: isRTL ? 'إغلاق' : 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildVendorNameField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: isRTL ? 'اسم المورد *' : 'Vendor Name *',
        hintText: isRTL ? 'أدخل اسم المورد' : 'Enter vendor name',
        prefixIcon: const Icon(Icons.store_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return isRTL ? 'يرجى إدخال اسم المورد' : 'Please enter vendor name';
        }
        return null;
      },
    );
  }

  Widget _buildCompanyNameField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _companyNameController,
      decoration: InputDecoration(
        labelText: isRTL ? 'اسم الشركة' : 'Company Name',
        hintText:
            isRTL
                ? 'أدخل اسم الشركة (اختياري)'
                : 'Enter company name (optional)',
        prefixIcon: const Icon(Icons.business_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildTypeDropdown(BuildContext context, bool isRTL, ThemeData theme) {
    return DropdownButtonFormField<VendorType>(
      value: _selectedType,
      isExpanded: true, // Ensures the dropdown takes full width
      decoration: InputDecoration(
        labelText: isRTL ? 'نوع المورد' : 'Vendor Type',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: VendorType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(type.icon, size: 18, color: type.color),
              const SizedBox(width: 12),
              Expanded( // This is the key: allows text to take remaining space
                child: Text(
                  isRTL ? type.arabicName : type.englishName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Ensures single-line with ellipsis
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
    );
  }
  Widget _buildStatusDropdown(
      BuildContext context,
      bool isRTL,
      ThemeData theme,
      ) {
    return DropdownButtonFormField<VendorStatus>(
      value: _selectedStatus,
      isExpanded: true, // Ensures the dropdown fills its container width
      decoration: InputDecoration(
        labelText: isRTL ? 'الحالة' : 'Status',
        prefixIcon: const Icon(Icons.check_circle_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: VendorStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded( // ← Key fix: allows text to flexibly take remaining space
                child: Text(
                  isRTL ? status.arabicName : status.englishName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Ensures single line with clean truncation
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  Widget _buildEmailField(BuildContext context, bool isRTL, ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
        hintText: isRTL ? 'example@company.com' : 'example@company.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return isRTL
                ? 'يرجى إدخال بريد إلكتروني صحيح'
                : 'Please enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(BuildContext context, bool isRTL, ThemeData theme) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: isRTL ? 'رقم الهاتف' : 'Phone Number',
        hintText: isRTL ? '+966 50 123 4567' : '+966 50 123 4567',
        prefixIcon: const Icon(Icons.phone_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildContactPersonField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _contactPersonController,
      decoration: InputDecoration(
        labelText: isRTL ? 'الشخص المسؤول' : 'Contact Person',
        hintText:
            isRTL ? 'اسم الشخص المسؤول للتواصل' : 'Name of contact person',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildAddressField(BuildContext context, bool isRTL, ThemeData theme) {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: isRTL ? 'العنوان' : 'Address',
        hintText: isRTL ? 'أدخل العنوان الكامل' : 'Enter full address',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildTaxNumberField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _taxNumberController,
      decoration: InputDecoration(
        labelText: isRTL ? 'الرقم الضريبي' : 'Tax Number',
        hintText: isRTL ? '123-456-789' : '123-456-789',
        prefixIcon: const Icon(Icons.receipt_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCommercialRegField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _commercialRegController,
      decoration: InputDecoration(
        labelText: isRTL ? 'السجل التجاري' : 'Commercial Registration',
        hintText: isRTL ? '987654321' : '987654321',
        prefixIcon: const Icon(Icons.badge_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBankAccountField(
    BuildContext context,
    bool isRTL,
    ThemeData theme,
  ) {
    return TextFormField(
      controller: _bankAccountController,
      decoration: InputDecoration(
        labelText: isRTL ? 'رقم الحساب البنكي' : 'Bank Account',
        hintText:
            isRTL
                ? 'EG380019000500000000123456789'
                : 'EG380019000500000000123456789',
        prefixIcon: const Icon(Icons.account_balance_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, bool isRTL, ThemeData theme) {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: isRTL ? 'ملاحظات' : 'Notes',
        hintText:
            isRTL ? 'أدخل أي ملاحظات إضافية' : 'Enter any additional notes',
        prefixIcon: const Icon(Icons.note_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 4,
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
    bool isEditing,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveVendor,
              style: ElevatedButton.styleFrom(
                backgroundColor: settings.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            settings.isDarkMode ? Colors.black : Colors.white,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing
                                ? Icons.save_outlined
                                : Icons.add_outlined,
                            color:
                                settings.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing
                                ? (isRTL ? 'حفظ التغييرات' : 'Save Changes')
                                : (isRTL ? 'إضافة مورد' : 'Add Vendor'),
                            style: TextStyle(
                              fontSize: 16,
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
        ],
      ),
    );
  }
}
