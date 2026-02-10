import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

/// Use case for deleting a vendor.
///
/// Permanently removes a vendor by its ID.
class DeleteVendorUseCase {
  final VendorRepository repository;

  DeleteVendorUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes the [vendorId] of the vendor to delete.
  Future<void> call(String vendorId) {
    return repository.deleteVendor(vendorId);
  }
}
