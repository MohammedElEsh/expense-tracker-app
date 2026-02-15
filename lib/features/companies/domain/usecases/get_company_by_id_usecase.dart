import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Fetches a company by id. In this system, returns my company if id matches.
class GetCompanyByIdUseCase {
  final CompanyRepository repository;

  GetCompanyByIdUseCase(this.repository);

  Future<CompanyEntity?> call(String id) {
    return repository.getCompanyById(id);
  }
}
