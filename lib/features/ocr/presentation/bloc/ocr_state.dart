import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

// OCR BLoC State
class OcrState extends Equatable {
  final File? selectedImage;
  final String? accountId;
  final String? category;
  final bool isScanning;
  final Expense? scannedExpense;
  final String? error;
  final bool isSuccess;

  const OcrState({
    this.selectedImage,
    this.accountId,
    this.category,
    this.isScanning = false,
    this.scannedExpense,
    this.error,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [
        selectedImage,
        accountId,
        category,
        isScanning,
        scannedExpense,
        error,
        isSuccess,
      ];

  OcrState copyWith({
    File? selectedImage,
    String? accountId,
    String? category,
    bool? isScanning,
    Expense? scannedExpense,
    String? error,
    bool? isSuccess,
    bool clearError = false,
    bool clearImage = false,
    bool clearScannedExpense = false,
  }) {
    return OcrState(
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      accountId: accountId ?? this.accountId,
      category: category ?? this.category,
      isScanning: isScanning ?? this.isScanning,
      scannedExpense: clearScannedExpense
          ? null
          : (scannedExpense ?? this.scannedExpense),
      error: clearError ? null : (error ?? this.error),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  bool get canScan {
    return selectedImage != null &&
        accountId != null &&
        accountId!.isNotEmpty &&
        !isScanning;
  }
}


