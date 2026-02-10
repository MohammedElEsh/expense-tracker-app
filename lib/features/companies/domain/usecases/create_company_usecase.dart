import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Use case for creating a new company.
///
/// Only available in business mode. The owner creates a company
/// that other users can then be invited to.
class CreateCompanyUseCase {
  final CompanyRepository repository;

  CreateCompanyUseCase(this.repository);

  /// Execute the use case.
  ///
  /// Takes a [Company] object with the desired fields and returns
  /// the newly created [Company] with server-assigned ID and timestamps.
  Future<Company> call(Company company) {
    return repository.createCompany(company);
  }
}
