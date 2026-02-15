import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class DeleteVendorUseCase {
  final VendorRepository repository;

  DeleteVendorUseCase(this.repository);

  Future<void> call(String vendorId) => repository.delete(vendorId);
}
