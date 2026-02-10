import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

/// Use case for updating an existing vendor.
///
/// Updates vendor fields such as name, type, status, contact info, etc.
class UpdateVendorUseCase {
  final VendorRepository repository;

  UpdateVendorUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes a [Vendor] object with updated fields and returns
  /// the updated [Vendor] from the server.
  Future<Vendor> call(Vendor vendor) {
    return repository.updateVendor(vendor);
  }
}
