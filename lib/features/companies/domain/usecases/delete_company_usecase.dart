import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

class DeleteCompanyUseCase {
  final CompanyRepository repository;

  DeleteCompanyUseCase(this.repository);

  Future<void> call() {
    return repository.deleteCompany();
  }
}
