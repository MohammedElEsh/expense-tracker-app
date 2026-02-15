import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';

/// Repository interface for company operations.
/// Implementations delegate to API/data sources and map to entities.
abstract class CompanyRepository {
  /// Get the current user's company (single company per user in business mode).
  Future<CompanyEntity?> getMyCompany({bool forceRefresh = false});

  /// Get company by id. In this system, effectively returns my company if id matches.
  Future<CompanyEntity?> getCompanyById(String id);

  /// Create a new company.
  Future<CompanyEntity> createCompany(CompanyEntity company);

  /// Update the current user's company.
  Future<CompanyEntity> updateCompany(CompanyEntity company);

  /// Delete the current user's company.
  Future<void> deleteCompany();

  void clearCache();
}
