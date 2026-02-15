import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';

/// Base state for OCR flow (Equatable).
/// Form fields (selectedImagePath, accountId, category) are carried across phases.
sealed class OcrState extends Equatable {
  const OcrState({
    this.selectedImagePath,
    this.accountId,
    this.category,
  });

  final String? selectedImagePath;
  final String? accountId;
  final String? category;

  @override
  List<Object?> get props => [selectedImagePath, accountId, category];
}

/// Initial state before any action.
final class OcrInitial extends OcrState {
  const OcrInitial({
    super.selectedImagePath,
    super.accountId,
    super.category,
  });
}

/// Scanning or parsing in progress.
final class OcrLoading extends OcrState {
  const OcrLoading({
    super.selectedImagePath,
    super.accountId,
    super.category,
  });
}

/// Parsing succeeded; [result] is the parsed receipt.
final class OcrSuccess extends OcrState {
  final OcrResultEntity result;

  const OcrSuccess(
    this.result, {
    super.selectedImagePath,
    super.accountId,
    super.category,
  });

  @override
  List<Object?> get props => [result, ...super.props];
}

/// An error occurred; [message] describes it.
final class OcrError extends OcrState {
  final String message;

  const OcrError(
    this.message, {
    super.selectedImagePath,
    super.accountId,
    super.category,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}

/// Convenience extension for UI (avoids casting in every builder).
extension OcrStateX on OcrState {
  bool get isSuccess => this is OcrSuccess;
  bool get isScanning => this is OcrLoading;
  String? get error => this is OcrError ? (this as OcrError).message : null;
  bool get canScan => selectedImagePath != null && selectedImagePath!.isNotEmpty;
  OcrResultEntity? get result =>
      this is OcrSuccess ? (this as OcrSuccess).result : null;
}
