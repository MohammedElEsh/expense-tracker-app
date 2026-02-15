import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

class GetVendorsStatisticsUseCase {
  final VendorRepository repository;

  GetVendorsStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call() => repository.getStatistics();
}
