import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';

/// Repository interface for vendor operations.
abstract class VendorRepository {
  Future<List<VendorEntity>> getAll();

  Future<VendorEntity?> getById(String vendorId);

  Future<VendorEntity> create(VendorEntity vendor);

  Future<VendorEntity> update(VendorEntity vendor);

  Future<void> delete(String vendorId);

  /// Statistics derived from current vendors (e.g. total count, active count).
  Future<Map<String, dynamic>> getStatistics();

  void clearCache();
}
