import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Use case for retrieving the current user's company.
///
/// In this system, a user belongs to a single company, so this
/// fetches "my company" rather than a list of companies.
class GetCompaniesUseCase {
  final CompanyRepository repository;

  GetCompaniesUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Returns the user's [Company] or `null` if none exists.
  /// Set [forceRefresh] to `true` to bypass the cache.
  Future<Company?> call({bool forceRefresh = false}) {
    return repository.getMyCompany(forceRefresh: forceRefresh);
  }
}
