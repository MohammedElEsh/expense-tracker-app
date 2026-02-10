import 'package:equatable/equatable.dart';
import 'dart:io';

// OCR BLoC Events
abstract class OcrEvent extends Equatable {
  const OcrEvent();

  @override
  List<Object?> get props => [];
}

class PickImageFromCamera extends OcrEvent {
  const PickImageFromCamera();
}

class PickImageFromGallery extends OcrEvent {
  const PickImageFromGallery();
}

class ImagePicked extends OcrEvent {
  final File imageFile;

  const ImagePicked(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class SetAccountId extends OcrEvent {
  final String accountId;

  const SetAccountId(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class SetCategory extends OcrEvent {
  final String? category;

  const SetCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ScanReceipt extends OcrEvent {
  const ScanReceipt();
}

class ClearImage extends OcrEvent {
  const ClearImage();
}

class ResetOcrState extends OcrEvent {
  const ResetOcrState();
}


