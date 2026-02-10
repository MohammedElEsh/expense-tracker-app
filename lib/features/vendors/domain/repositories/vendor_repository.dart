import 'package:expense_tracker/features/vendors/data/models/vendor.dart';

/// Abstract repository interface for vendor operations.
///
/// Defines the contract for vendor data access. Implementations
/// handle the actual data fetching (API, local cache, etc.).
abstract class VendorRepository {
  /// Get all vendors.
  ///
  /// Returns a list of all [Vendor] objects.
  Future<List<Vendor>> getAllVendors();

  /// Get filtered vendors with pagination.
  ///
  /// Supports server-side filtering by [search], [status], [type],
  /// and sorting via [sort]. Pagination is controlled by [page] and [limit].
  /// Returns a map containing 'vendors' and 'pagination' data.
  Future<Map<String, dynamic>> getFilteredVendors({
    int page = 1,
    int limit = 20,
    String? search,
    VendorStatus? status,
    VendorType? type,
    String? sort,
  });

  /// Get a single vendor by its [vendorId].
  ///
  /// Returns `null` if not found.
  Future<Vendor?> getVendorById(String vendorId);

  /// Create a new vendor.
  ///
  /// Returns the created [Vendor] with server-assigned ID.
  Future<Vendor> createVendor(Vendor vendor);

  /// Update an existing vendor.
  ///
  /// Returns the updated [Vendor].
  Future<Vendor> updateVendor(Vendor vendor);

  /// Delete a vendor by its [vendorId].
  Future<void> deleteVendor(String vendorId);

  /// Clear any cached vendor data.
  void clearCache();
}
