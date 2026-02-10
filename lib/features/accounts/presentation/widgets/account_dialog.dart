// ✅ Account Dialog - Refactored (Simplified)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/accounts/presentation/cubit/account_cubit.dart';

class AccountDialog extends StatefulWidget {
  final Account? account;

  const AccountDialog({super.key, this.account});

  @override
  State<AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<AccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _selectedType = AccountType.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _initializeWithAccount(widget.account!);
    }
  }

  void _initializeWithAccount(Account account) {
    _nameController.text = account.name;
    _balanceController.text = account.balance.toString();
    _selectedType = account.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isEditing = widget.account != null;
      final accountCubit = context.read<AccountCubit>();

      if (isEditing) {
        // Update existing account via Cubit
        final account = widget.account!.copyWith(
          name: _nameController.text.trim(),
          balance: double.parse(_balanceController.text),
          type: _selectedType,
        );
        accountCubit.updateAccount(account);
      } else {
        // Add new account via Cubit
        final account = Account(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          balance: double.parse(_balanceController.text),
          type: _selectedType,
          currency:
              SettingsService
                  .currency, // Use app's current currency (SAR, USD, EGP, etc.)
          createdAt: DateTime.now(),
        );
        accountCubit.addAccount(account);
      }

      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsCubit>().state.language == 'ar';
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
    final isEditing = widget.account != null;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.borderRadius),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? maxWidth : 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing
                                ? (isRTL ? 'تعديل الحساب' : 'Edit Account')
                                : (isRTL ? 'حساب جديد' : 'New Account'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  settings.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
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
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Account Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText:
                                isRTL ? 'اسم الحساب *' : 'Account Name *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isRTL
                                  ? 'يرجى إدخال اسم الحساب'
                                  : 'Please enter account name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Balance
                        TextFormField(
                          controller: _balanceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d+\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: isRTL ? 'الرصيد *' : 'Balance *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.attach_money),
                            prefixText: '${settings.currencySymbol} ',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return isRTL
                                  ? 'يرجى إدخال الرصيد'
                                  : 'Please enter balance';
                            }
                            final balance = double.tryParse(value);
                            if (balance == null) {
                              return isRTL
                                  ? 'رصيد غير صحيح'
                                  : 'Invalid balance';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Account Type
                        DropdownButtonFormField<AccountType>(
                          initialValue: _selectedType,
                          decoration: InputDecoration(
                            labelText:
                                isRTL ? 'نوع الحساب *' : 'Account Type *',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              _getAccountTypeIcon(_selectedType),
                            ),
                          ),
                          items:
                              AccountType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(_getAccountTypeIcon(type), size: 20),
                                      const SizedBox(width: 12),
                                      Text(_getAccountTypeLabel(type, isRTL)),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settings.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  isEditing
                                      ? (isRTL ? 'تحديث' : 'Update')
                                      : (isRTL ? 'إضافة' : 'Add'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        settings.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                  ),
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

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.cash:
        return Icons.money;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.debit:
        return Icons.payment;
      case AccountType.digital:
        return Icons.account_balance_wallet;
      case AccountType.gift:
        return Icons.card_giftcard;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.savings:
        return Icons.savings;
    }
  }

  String _getAccountTypeLabel(AccountType type, bool isRTL) {
    if (!isRTL) {
      return type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
    }
    switch (type) {
      case AccountType.bank:
        return 'بنكي';
      case AccountType.cash:
        return 'نقدي';
      case AccountType.credit:
        return 'بطاقة ائتمان';
      case AccountType.debit:
        return 'بطاقة خصم مباشر';
      case AccountType.digital:
        return 'محفظة رقمية';
      case AccountType.gift:
        return 'بطاقة هدية';
      case AccountType.investment:
        return 'استثمار';
      case AccountType.savings:
        return 'توفير';
    }
  }
}
