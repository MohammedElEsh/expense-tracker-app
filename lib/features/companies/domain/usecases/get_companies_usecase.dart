import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Fetches the current user's company (single company in business mode).
class GetCompaniesUseCase {
  final CompanyRepository repository;

  GetCompaniesUseCase(this.repository);

  Future<CompanyEntity?> call({bool forceRefresh = false}) {
    return repository.getMyCompany(forceRefresh: forceRefresh);
  }
}
