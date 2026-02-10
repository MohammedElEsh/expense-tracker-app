// ✅ OCR Feature - Presentation Layer - OCR Scanner Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/features/ocr/presentation/bloc/ocr_bloc.dart';
import 'package:expense_tracker/features/ocr/presentation/bloc/ocr_event.dart';
import 'package:expense_tracker/features/ocr/presentation/bloc/ocr_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:expense_tracker/features/accounts/presentation/bloc/account_state.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog_refactored.dart';
import 'package:expense_tracker/constants/categories.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';

class OCRScannerScreen extends StatelessWidget {
  const OCRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OcrBloc(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
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
                  isRTL ? 'مسح الفواتير' : 'Scan Receipt',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              body: BlocConsumer<OcrBloc, OcrState>(
                listener: (context, state) {
                  // Handle success - navigate to expense form with pre-filled data
                  if (state.isSuccess && state.scannedExpense != null) {
                    final expense = state.scannedExpense!;

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isRTL
                                    ? 'تم مسح الفاتورة بنجاح!'
                                    : 'Receipt scanned successfully!',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // Navigate to expense form with pre-filled data
                    Navigator.of(context).pushWithAnimation(
                      AddExpenseDialogRefactored(
                        selectedDate: expense.date,
                        expenseToEdit: expense,
                      ),
                      animationType: AnimationType.slideUp,
                    );

                    // Reset OCR state after navigation
                    context.read<OcrBloc>().add(const ResetOcrState());
                  }

                  // Handle errors
                  if (state.error != null && !state.isScanning) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
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
                },
                builder: (context, ocrState) {
                  return Container(
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
                    child: SafeArea(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<OcrBloc>().add(const ResetOcrState());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Section
                              _buildHeader(context, settings, isRTL),
                              const SizedBox(height: 24),

                              // Image Preview Section
                              if (ocrState.selectedImage != null)
                                _buildImagePreview(
                                  context,
                                  ocrState.selectedImage!,
                                  settings,
                                  isRTL,
                                )
                              else
                                _buildImagePlaceholder(
                                  context,
                                  settings,
                                  isRTL,
                                ),

                              const SizedBox(height: 24),

                              // Account Selection
                              _buildAccountSelector(
                                context,
                                settings,
                                isRTL,
                                ocrState.accountId,
                              ),

                              const SizedBox(height: 16),

                              // Category Selection (Optional)
                              _buildCategorySelector(
                                context,
                                settings,
                                isRTL,
                                ocrState.category,
                              ),

                              const SizedBox(height: 24),

                              // Action Buttons
                              _buildActionButtons(
                                context,
                                settings,
                                isRTL,
                                ocrState,
                              ),

                              const SizedBox(height: 16),

                              // Loading Indicator
                              if (ocrState.isScanning)
                                _buildLoadingIndicator(settings, isRTL),

                              // Scanned Results Preview
                              if (ocrState.scannedExpense != null &&
                                  !ocrState.isScanning)
                                _buildScannedResultsPreview(
                                  context,
                                  ocrState.scannedExpense!,
                                  settings,
                                  isRTL,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: settings.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long,
            size: 48,
            color: settings.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isRTL
              ? 'مسح الفواتير بالذكاء الاصطناعي'
              : 'AI-Powered Receipt Scanning',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isRTL
              ? 'التقط صورة للفاتورة وسنقوم باستخراج المعلومات تلقائياً'
              : 'Take a photo of your receipt and we\'ll extract the information automatically',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: settings.primaryTextColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
  ) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settings.primaryColor.withValues(alpha: 0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: settings.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'لم يتم اختيار صورة' : 'No image selected',
            style: TextStyle(
              fontSize: 16,
              color: settings.primaryTextColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    BuildContext context,
    File imageFile,
    SettingsState settings,
    bool isRTL,
  ) {
    return Stack(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: settings.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
            onPressed: () {
              context.read<OcrBloc>().add(const ClearImage());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
    String? selectedAccountId,
  ) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, accountState) {
        final accounts = accountState.activeAccounts;

        if (accounts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isRTL
                        ? 'لا توجد حسابات. يرجى إضافة حساب أولاً.'
                        : 'No accounts available. Please add an account first.',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: settings.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selectedAccountId == null
                      ? Colors.red.withValues(alpha: 0.5)
                      : settings.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedAccountId,
            decoration: InputDecoration(
              labelText: isRTL ? 'الحساب *' : 'Account *',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: settings.primaryColor,
              ),
              helperText: isRTL ? 'مطلوب' : 'Required',
            ),
            items:
                accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Row(
                      children: [
                        Icon(account.icon, size: 20),
                        const SizedBox(width: 12),
                        Text(account.name),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<OcrBloc>().add(SetAccountId(value));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isRTL ? 'الحساب مطلوب' : 'Account is required';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
    String? selectedCategory,
  ) {
    final categories = Categories.reorderCategories(
      Categories.getCategoriesForMode(settings.isBusinessMode),
    );
    final categoryIcon =
        selectedCategory != null
            ? Categories.getIcon(selectedCategory)
            : Icons.category;

    return Container(
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: settings.primaryColor.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: isRTL ? 'الفئة (اختياري)' : 'Category (Optional)',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(categoryIcon, color: settings.primaryColor),
          helperText:
              isRTL
                  ? 'اختياري - سيتم تخمينها تلقائياً'
                  : 'Optional - will be auto-detected',
        ),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(
              isRTL ? 'تخمين تلقائي' : 'Auto-detect',
              style: TextStyle(
                color: settings.primaryTextColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          ...categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(Categories.getIcon(category), size: 20),
                  const SizedBox(width: 12),
                  Text(Categories.getDisplayName(category, isRTL)),
                ],
              ),
            );
          }),
        ],
        onChanged: (value) {
          context.read<OcrBloc>().add(SetCategory(value));
        },
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SettingsState settings,
    bool isRTL,
    OcrState ocrState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image Selection Buttons
        if (ocrState.selectedImage == null) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      ocrState.isScanning
                          ? null
                          : () {
                            context.read<OcrBloc>().add(
                              const PickImageFromCamera(),
                            );
                          },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(isRTL ? 'التقط صورة' : 'Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.primaryColor,
                    foregroundColor:
                        settings.isDarkMode ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      ocrState.isScanning
                          ? null
                          : () {
                            context.read<OcrBloc>().add(
                              const PickImageFromGallery(),
                            );
                          },
                  icon: const Icon(Icons.photo_library),
                  label: Text(isRTL ? 'اختر من المعرض' : 'Choose from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: settings.surfaceColor,
                    foregroundColor: settings.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: settings.primaryColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Scan Button
          ElevatedButton.icon(
            onPressed:
                ocrState.canScan && !ocrState.isScanning
                    ? () {
                      context.read<OcrBloc>().add(const ScanReceipt());
                    }
                    : null,
            icon: const Icon(Icons.scanner),
            label: Text(
              isRTL ? 'مسح الفاتورة' : 'Scan Receipt',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  ocrState.canScan ? settings.primaryColor : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Retake/Change Image Button
          OutlinedButton.icon(
            onPressed:
                ocrState.isScanning
                    ? null
                    : () {
                      context.read<OcrBloc>().add(const ClearImage());
                    },
            icon: const Icon(Icons.refresh),
            label: Text(isRTL ? 'اختر صورة أخرى' : 'Choose Another Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: settings.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: settings.primaryColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(SettingsState settings, bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: settings.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isRTL ? 'جاري مسح الفاتورة...' : 'Scanning receipt...',
            style: TextStyle(fontSize: 16, color: settings.primaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedResultsPreview(
    BuildContext context,
    expense,
    SettingsState settings,
    bool isRTL,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                isRTL ? 'تم استخراج البيانات' : 'Data Extracted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: settings.primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            Icons.attach_money,
            isRTL ? 'المبلغ' : 'Amount',
            '${expense.amount.toStringAsFixed(2)}',
            settings,
          ),
          const SizedBox(height: 12),
          _buildResultRow(
            Categories.getIcon(expense.category),
            isRTL ? 'الفئة' : 'Category',
            expense.getDisplayCategoryName(),
            settings,
          ),
          if (expense.vendorName != null && expense.vendorName!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.store,
              isRTL ? 'المورد' : 'Vendor',
              expense.vendorName!,
              settings,
            ),
          ],
          if (expense.date != null) ...[
            const SizedBox(height: 12),
            _buildResultRow(
              Icons.calendar_today,
              isRTL ? 'التاريخ' : 'Date',
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              settings,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(
    IconData icon,
    String label,
    String value,
    SettingsState settings,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: settings.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: settings.primaryTextColor.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: settings.primaryTextColor,
          ),
        ),
      ],
    );
  }
}
