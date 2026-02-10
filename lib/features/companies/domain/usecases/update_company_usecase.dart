import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Use case for updating an existing company.
///
/// Updates the current user's company with the provided fields.
class UpdateCompanyUseCase {
  final CompanyRepository repository;

  UpdateCompanyUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes a [Company] object with updated fields and returns
  /// the updated [Company] from the server.
  Future<Company> call(Company company) {
    return repository.updateCompany(company);
  }
}
