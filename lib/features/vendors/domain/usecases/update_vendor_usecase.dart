import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class UpdateVendorUseCase {
  final VendorRepository repository;

  UpdateVendorUseCase(this.repository);

  Future<VendorEntity> call(VendorEntity vendor) => repository.update(vendor);
}
