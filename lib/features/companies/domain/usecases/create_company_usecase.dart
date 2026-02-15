import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

class CreateCompanyUseCase {
  final CompanyRepository repository;

  CreateCompanyUseCase(this.repository);

  Future<CompanyEntity> call(CompanyEntity company) {
    return repository.createCompany(company);
  }
}
