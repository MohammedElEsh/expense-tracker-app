import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/ocr/domain/entities/ocr_result_entity.dart';
import 'package:expense_tracker/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/create_expense_from_ocr_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/parse_receipt_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/pick_image_usecase.dart';
import 'package:expense_tracker/features/ocr/domain/usecases/scan_receipt_usecase.dart';
import 'package:expense_tracker/features/ocr/presentation/cubit/ocr_state.dart';

/// OCR Cubit: depends only on use cases (no direct service/datasource calls).
class OcrCubit extends Cubit<OcrState> {
  final PickImageUseCase pickImageUseCase;
  final ScanReceiptUseCase scanReceiptUseCase;
  final ParseReceiptUseCase parseReceiptUseCase;
  final CreateExpenseFromOcrUseCase createExpenseFromOcrUseCase;

  OcrCubit({
    required this.pickImageUseCase,
    required this.scanReceiptUseCase,
    required this.parseReceiptUseCase,
    required this.createExpenseFromOcrUseCase,
  }) : super(const OcrInitial());

  /// Pick image from camera and update state with path.
  Future<void> pickImageFromCamera() async {
    final path = await pickImageUseCase(OcrImageSource.camera);
    if (path == null || !isClosed) return;
    emit(OcrInitial(
      selectedImagePath: path,
      accountId: state.accountId,
      category: state.category,
    ));
  }

  /// Pick image from gallery and update state with path.
  Future<void> pickImageFromGallery() async {
    final path = await pickImageUseCase(OcrImageSource.gallery);
    if (path == null || !isClosed) return;
    emit(OcrInitial(
      selectedImagePath: path,
      accountId: state.accountId,
      category: state.category,
    ));
  }

  /// Clear selected image; keep account and category.
  void clearImage() {
    emit(OcrInitial(
      selectedImagePath: null,
      accountId: state.accountId,
      category: state.category,
    ));
  }

  void setAccountId(String? value) {
    emit(_copyWith(accountId: value));
  }

  void setCategory(String? value) {
    emit(_copyWith(category: value));
  }

  /// Pick image from camera, then scan and parse in one flow (for simple "Scan" button).
  Future<void> scanAndParse() async {
    await pickImageFromCamera();
    if (isClosed) return;
    final path = state.selectedImagePath;
    if (path != null && path.isNotEmpty) {
      await scanReceipt();
    }
  }

  /// Scan receipt using selected image, then parse; emits Loading → Success/Error.
  Future<void> scanReceipt() async {
    final path = state.selectedImagePath;
    if (path == null || path.isEmpty) {
      emit(OcrError(
        'Please select an image first',
        selectedImagePath: state.selectedImagePath,
        accountId: state.accountId,
        category: state.category,
      ));
      return;
    }
    emit(OcrLoading(
      selectedImagePath: state.selectedImagePath,
      accountId: state.accountId,
      category: state.category,
    ));
    try {
      final ref = await scanReceiptUseCase(path);
      final result = await parseReceiptUseCase(ref);
      if (!isClosed) {
        emit(OcrSuccess(
          result,
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(OcrError(
          e.toString(),
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    }
  }

  /// Reset to initial state (no image, no account/category, no result).
  void resetOcrState() {
    emit(const OcrInitial());
  }

  /// Parse raw input (e.g. manual entry); optional, for future use.
  Future<void> parseInput(String input) async {
    if (input.trim().isEmpty) {
      emit(OcrError(
        'Input is empty',
        selectedImagePath: state.selectedImagePath,
        accountId: state.accountId,
        category: state.category,
      ));
      return;
    }
    emit(OcrLoading(
      selectedImagePath: state.selectedImagePath,
      accountId: state.accountId,
      category: state.category,
    ));
    try {
      final result = await parseReceiptUseCase(input.trim());
      if (!isClosed) {
        emit(OcrSuccess(
          result,
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(OcrError(
          e.toString(),
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    }
  }

  /// Create expense from current result (call after Success).
  Future<void> createExpenseFromResult(OcrResultEntity result) async {
    emit(OcrLoading(
      selectedImagePath: state.selectedImagePath,
      accountId: state.accountId,
      category: state.category,
    ));
    try {
      await createExpenseFromOcrUseCase(result);
      if (!isClosed) {
        emit(OcrSuccess(
          result,
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(OcrError(
          e.toString(),
          selectedImagePath: state.selectedImagePath,
          accountId: state.accountId,
          category: state.category,
        ));
      }
    }
  }

  OcrState _copyWith({String? accountId, String? category}) {
    final a = accountId ?? state.accountId;
    final c = category ?? state.category;
    if (state is OcrSuccess) {
      return OcrSuccess((state as OcrSuccess).result,
          selectedImagePath: state.selectedImagePath, accountId: a, category: c);
    }
    if (state is OcrError) {
      return OcrError((state as OcrError).message,
          selectedImagePath: state.selectedImagePath, accountId: a, category: c);
    }
    if (state is OcrLoading) {
      return OcrLoading(
          selectedImagePath: state.selectedImagePath, accountId: a, category: c);
    }
    return OcrInitial(
        selectedImagePath: state.selectedImagePath, accountId: a, category: c);
  }
}
