import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class GetVendorByIdUseCase {
  final VendorRepository repository;

  GetVendorByIdUseCase(this.repository);

  Future<VendorEntity?> call(String vendorId) => repository.getById(vendorId);
}
