// ✅ OCR Feature - Presentation Layer - OCR Scanner Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/di/injection.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/add_expense_dialog.dart';
import 'package:expense_tracker/features/ocr/presentation/cubit/ocr_cubit.dart';
import 'package:expense_tracker/features/ocr/presentation/cubit/ocr_state.dart';
import 'package:expense_tracker/features/ocr/presentation/utils/ocr_result_to_expense_mapper.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_header_section.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_image_placeholder.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_image_preview.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_account_selector.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_category_selector.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_action_buttons.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_loading_indicator.dart';
import 'package:expense_tracker/features/ocr/presentation/widgets/ocr_scanned_results_preview.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart' as project_data;
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_state.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';

class OCRScannerScreen extends StatelessWidget {
  const OCRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OcrCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
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
              body: BlocConsumer<OcrCubit, OcrState>(
                listener: (context, state) {
                  _handleOcrStateChanges(context, state, isRTL, settings);
                },
                builder: (context, ocrState) {
                  return _OcrScannerBody(
                    settings: settings,
                    isRTL: isRTL,
                    ocrState: ocrState,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleOcrStateChanges(
    BuildContext context,
    OcrState state,
    bool isRTL,
    SettingsState settings,
  ) {
    // Handle success - navigate to expense form with pre-filled data
    if (state.isSuccess && state.result != null) {
      final expense = mapOcrResultToExpense(
        state.result!,
        accountId: state.accountId,
        category: state.category,
        appMode: settings.appMode,
        photoPath: state.selectedImagePath,
      );

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

      final projectCubit = context.read<ProjectCubit>();
      final vendorCubit = context.read<VendorCubit>();
      final projectState = projectCubit.state;
      final projectEntities = projectState is ProjectLoaded
          ? projectState.projects
              .where((p) =>
                  p.status != ProjectStatus.cancelled &&
                  p.status != ProjectStatus.completed)
              .toList()
          : <ProjectEntity>[];
      final projects = projectEntities
          .map((p) => project_data.Project(
                id: p.id,
                name: p.name,
                description: p.description,
                status: project_data.ProjectStatus.values.firstWhere(
                  (s) => s.name == p.status.name,
                  orElse: () => project_data.ProjectStatus.planning,
                ),
                startDate: p.startDate,
                endDate: p.endDate,
                budget: p.budget,
                spentAmount: p.spentAmount,
                managerName: p.managerName,
                clientName: p.clientName,
                priority: p.priority,
                createdAt: p.createdAt,
                updatedAt: p.updatedAt,
              ))
          .toList();
      final vendorState = vendorCubit.state;
      final vendorNames = vendorState is VendorLoaded
          ? vendorState.vendors.map((v) => v.name).toList()
          : <String>[];
      showDialog<void>(
        context: context,
        builder: (ctx) => AddExpenseDialog.createWithCubit(
          ctx,
          selectedDate: expense.date,
          expenseToEdit: expense,
          projects: projects,
          vendorNames: vendorNames,
        ),
      );

      context.read<OcrCubit>().resetOcrState();
    }

    // Handle errors
    if (state.error != null && !state.isScanning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
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
  }
}

class _OcrScannerBody extends StatelessWidget {
  const _OcrScannerBody({
    required this.settings,
    required this.isRTL,
    required this.ocrState,
  });

  final SettingsState settings;
  final bool isRTL;
  final OcrState ocrState;

  @override
  Widget build(BuildContext context) {
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
            context.read<OcrCubit>().resetOcrState();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OcrHeaderSection(settings: settings, isRTL: isRTL),
                const SizedBox(height: 24),

                if (ocrState.selectedImagePath != null)
                  OcrImagePreview(
                    imageFile: File(ocrState.selectedImagePath!),
                    settings: settings,
                    onClearImage: () => context.read<OcrCubit>().clearImage(),
                  )
                else
                  OcrImagePlaceholder(settings: settings, isRTL: isRTL),

                const SizedBox(height: 24),

                OcrAccountSelector(
                  settings: settings,
                  isRTL: isRTL,
                  selectedAccountId: ocrState.accountId,
                  onAccountChanged:
                      (value) => context.read<OcrCubit>().setAccountId(value),
                ),

                const SizedBox(height: 16),

                OcrCategorySelector(
                  settings: settings,
                  isRTL: isRTL,
                  selectedCategory: ocrState.category,
                  onCategoryChanged:
                      (value) => context.read<OcrCubit>().setCategory(value),
                ),

                const SizedBox(height: 24),

                OcrActionButtons(
                  settings: settings,
                  isRTL: isRTL,
                  hasImage: ocrState.selectedImagePath != null,
                  isScanning: ocrState.isScanning,
                  canScan: ocrState.canScan,
                  onPickCamera:
                      () => context.read<OcrCubit>().pickImageFromCamera(),
                  onPickGallery:
                      () => context.read<OcrCubit>().pickImageFromGallery(),
                  onScan: () => context.read<OcrCubit>().scanReceipt(),
                  onClearImage: () => context.read<OcrCubit>().clearImage(),
                ),

                const SizedBox(height: 16),

                if (ocrState.isScanning)
                  OcrLoadingIndicator(settings: settings, isRTL: isRTL),

                if (ocrState.result != null && !ocrState.isScanning)
                  OcrScannedResultsPreview(
                    expense: mapOcrResultToExpense(
                      ocrState.result!,
                      accountId: ocrState.accountId,
                      category: ocrState.category,
                      appMode: settings.appMode,
                    ),
                    settings: settings,
                    isRTL: isRTL,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
