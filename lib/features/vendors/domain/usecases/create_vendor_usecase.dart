import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

/// Use case for creating a new vendor.
///
/// Creates a vendor (supplier, service provider, contractor, etc.)
/// and returns the server-created entity.
class CreateVendorUseCase {
  final VendorRepository repository;

  CreateVendorUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes a [Vendor] object with the desired fields and returns
  /// the newly created [Vendor] with server-assigned ID and timestamps.
  Future<Vendor> call(Vendor vendor) {
    return repository.createVendor(vendor);
  }
}
