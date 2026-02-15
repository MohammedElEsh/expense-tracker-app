import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/domain/entities/owner_info_entity.dart';
import 'package:expense_tracker/features/companies/domain/repositories/company_repository.dart';

/// Implementation of [CompanyRepository].
/// Delegates to [CompanyApiService] and maps data models to domain entities.
class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyApiService _apiService;

  CompanyRepositoryImpl({required CompanyApiService companyApiService})
      : _apiService = companyApiService;

  @override
  void clearCache() => _apiService.clearCache();

  @override
  Future<CompanyEntity?> getMyCompany({bool forceRefresh = false}) async {
    final company = await _apiService.getMyCompany(forceRefresh: forceRefresh);
    return _modelToEntity(company);
  }

  @override
  Future<CompanyEntity?> getCompanyById(String id) async {
    final company = await _apiService.getMyCompany(forceRefresh: true);
    if (company == null || company.id != id) return null;
    return _modelToEntity(company);
  }

  @override
  Future<CompanyEntity> createCompany(CompanyEntity entity) async {
    final model = _entityToModel(entity);
    final created = await _apiService.createCompany(model);
    return _modelToEntity(created)!;
  }

  @override
  Future<CompanyEntity> updateCompany(CompanyEntity entity) async {
    final model = _entityToModel(entity);
    final updated = await _apiService.updateCompany(model);
    return _modelToEntity(updated)!;
  }

  @override
  Future<void> deleteCompany() => _apiService.deleteCompany();

  CompanyEntity? _modelToEntity(Company? m) {
    if (m == null) return null;
    return CompanyEntity(
      id: m.id,
      name: m.name,
      taxNumber: m.taxNumber,
      address: m.address,
      phone: m.phone,
      currency: m.currency,
      fiscalYearStart: m.fiscalYearStart,
      isActive: m.isActive,
      employeeCount: m.employeeCount,
      currentEmployeeCount: m.currentEmployeeCount,
      ownerEmail: m.ownerEmail,
      ownerId: m.ownerId == null
          ? null
          : OwnerInfoEntity(
              id: m.ownerId!.id,
              name: m.ownerId!.name,
              email: m.ownerId!.email,
              phone: m.ownerId!.phone,
            ),
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
    );
  }

  Company _entityToModel(CompanyEntity e) {
    return Company(
      id: e.id,
      name: e.name,
      taxNumber: e.taxNumber,
      address: e.address,
      phone: e.phone,
      currency: e.currency,
      fiscalYearStart: e.fiscalYearStart,
      isActive: e.isActive,
      employeeCount: e.employeeCount,
      currentEmployeeCount: e.currentEmployeeCount,
      ownerEmail: e.ownerEmail,
      ownerId: e.ownerId == null
          ? null
          : OwnerInfo(
              id: e.ownerId!.id,
              name: e.ownerId!.name,
              email: e.ownerId!.email,
              phone: e.ownerId!.phone,
            ),
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }
}
