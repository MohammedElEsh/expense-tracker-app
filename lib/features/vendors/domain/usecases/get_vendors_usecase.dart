import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

/// Use case for retrieving all vendors.
///
/// Fetches the complete list of vendors from the repository.
class GetVendorsUseCase {
  final VendorRepository repository;

  GetVendorsUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Returns a list of all [Vendor] objects.
  Future<List<Vendor>> call() {
    return repository.getAllVendors();
  }
}
