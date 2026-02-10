import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/expenses/data/datasources/expense_api_service.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

// OCR BLoC
class OcrBloc extends Bloc<OcrEvent, OcrState> {
  final ExpenseApiService _expenseApiService;
  final ImagePicker _imagePicker;

  OcrBloc({
    ExpenseApiService? expenseApiService,
    ImagePicker? imagePicker,
  })  : _expenseApiService =
            expenseApiService ?? serviceLocator.expenseApiService,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const OcrState()) {
    on<PickImageFromCamera>(_onPickImageFromCamera);
    on<PickImageFromGallery>(_onPickImageFromGallery);
    on<ImagePicked>(_onImagePicked);
    on<SetAccountId>(_onSetAccountId);
    on<SetCategory>(_onSetCategory);
    on<ScanReceipt>(_onScanReceipt);
    on<ClearImage>(_onClearImage);
    on<ResetOcrState>(_onResetOcrState);
  }

  Future<void> _onPickImageFromCamera(
    PickImageFromCamera event,
    Emitter<OcrState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        add(ImagePicked(File(pickedFile.path)));
      }
    } catch (e) {
      debugPrint('❌ Error picking image from camera: $e');
      emit(state.copyWith(
        error: 'Failed to pick image from camera: $e',
        clearError: false,
      ));
    }
  }

  Future<void> _onPickImageFromGallery(
    PickImageFromGallery event,
    Emitter<OcrState> emit,
  ) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        add(ImagePicked(File(pickedFile.path)));
      }
    } catch (e) {
      debugPrint('❌ Error picking image from gallery: $e');
      emit(state.copyWith(
        error: 'Failed to pick image from gallery: $e',
        clearError: false,
      ));
    }
  }

  void _onImagePicked(
    ImagePicked event,
    Emitter<OcrState> emit,
  ) {
    emit(state.copyWith(
      selectedImage: event.imageFile,
      clearError: true,
      isSuccess: false,
      clearScannedExpense: true,
    ));
  }

  void _onSetAccountId(
    SetAccountId event,
    Emitter<OcrState> emit,
  ) {
    emit(state.copyWith(
      accountId: event.accountId,
      clearError: true,
    ));
  }

  void _onSetCategory(
    SetCategory event,
    Emitter<OcrState> emit,
  ) {
    emit(state.copyWith(
      category: event.category,
      clearError: true,
    ));
  }

  Future<void> _onScanReceipt(
    ScanReceipt event,
    Emitter<OcrState> emit,
  ) async {
    if (!state.canScan) {
      emit(state.copyWith(
        error: 'Please select an image and account before scanning',
      ));
      return;
    }

    emit(state.copyWith(
      isScanning: true,
      clearError: true,
      isSuccess: false,
      clearScannedExpense: true,
    ));

    try {
      final scannedExpense = await _expenseApiService.scanReceipt(
        receiptImage: state.selectedImage!,
        accountId: state.accountId!,
        category: state.category,
      );

      // ✅ OCR Category Handling Fix:
      // When OCR detects a category, always set selected category = "أخرى"
      // and put the OCR detected value into customCategory field
      // Do NOT try to match OCR category with predefined categories
      Expense processedExpense = scannedExpense;
      if (scannedExpense.category.isNotEmpty && 
          scannedExpense.category != 'أخرى') {
        // OCR detected a category - set to "أخرى" and move detected category to customCategory
        final detectedCategory = scannedExpense.category;
        processedExpense = scannedExpense.copyWith(
          category: 'أخرى',
          customCategory: detectedCategory,
        );
        debugPrint('📝 OCR detected category "$detectedCategory" - set to "أخرى" with customCategory');
      }

      emit(state.copyWith(
        isScanning: false,
        scannedExpense: processedExpense,
        isSuccess: true,
        clearError: true,
      ));

      debugPrint('✅ Receipt scanned successfully');
      debugPrint('   Amount: ${processedExpense.amount}');
      debugPrint('   Category: ${processedExpense.category}');
      debugPrint('   CustomCategory: ${processedExpense.customCategory ?? 'N/A'}');
      debugPrint('   Vendor: ${processedExpense.vendorName ?? 'N/A'}');
    } on ValidationException catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: e.message,
        isSuccess: false,
      ));
    } on UnauthorizedException catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: e.message,
        isSuccess: false,
      ));
    } on NetworkException catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: e.message,
        isSuccess: false,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        isScanning: false,
        error: e.message,
        isSuccess: false,
      ));
    } catch (e) {
      debugPrint('❌ Error scanning receipt: $e');
      emit(state.copyWith(
        isScanning: false,
        error: 'Failed to scan receipt: ${e.toString()}',
        isSuccess: false,
      ));
    }
  }

  void _onClearImage(
    ClearImage event,
    Emitter<OcrState> emit,
  ) {
    emit(state.copyWith(
      clearImage: true,
      clearScannedExpense: true,
      isSuccess: false,
      clearError: true,
    ));
  }

  void _onResetOcrState(
    ResetOcrState event,
    Emitter<OcrState> emit,
  ) {
    emit(const OcrState());
  }
}


