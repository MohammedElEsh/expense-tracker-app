import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class CreateVendorUseCase {
  final VendorRepository repository;

  CreateVendorUseCase(this.repository);

  Future<VendorEntity> call(VendorEntity vendor) => repository.create(vendor);
}
