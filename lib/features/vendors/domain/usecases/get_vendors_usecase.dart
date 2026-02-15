import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class GetVendorsUseCase {
  final VendorRepository repository;

  GetVendorsUseCase(this.repository);

  Future<List<VendorEntity>> call() => repository.getAll();
}
