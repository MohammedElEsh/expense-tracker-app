import 'package:expense_tracker/features/companies/data/models/company.dart';

/// Abstract repository interface for company operations.
///
/// Defines the contract for company data access. Implementations
/// handle the actual data fetching (API, local cache, etc.).
abstract class CompanyRepository {
  /// Get the current user's company.
  ///
  /// Returns `null` if no company is found or if the user is not in business mode.
  /// Set [forceRefresh] to `true` to bypass cached data.
  Future<Company?> getMyCompany({bool forceRefresh = false});

  /// Create a new company.
  ///
  /// Only available in business mode. Returns the created [Company].
  Future<Company> createCompany(Company company);

  /// Update the current user's company.
  ///
  /// Returns the updated [Company].
  Future<Company> updateCompany(Company company);

  /// Delete the current user's company.
  Future<void> deleteCompany();

  /// Clear any cached company data.
  void clearCache();
}
