import 'package:expense_tracker/features/vendors/data/datasources/vendor_service.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart' as model;
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';
import 'package:expense_tracker/features/vendors/domain/repositories/vendor_repository.dart';

/// Implementation of [VendorRepository]. Delegates to [VendorService] and maps models to entities.
class VendorRepositoryImpl implements VendorRepository {
  final VendorService _service;

  VendorRepositoryImpl({required VendorService vendorService}) : _service = vendorService;

  @override
  void clearCache() => _service.clearCache();

  @override
  Future<List<VendorEntity>> getAll() async {
    final list = await _service.getAllVendors();
    return list.map(_modelToEntity).toList();
  }

  @override
  Future<VendorEntity?> getById(String vendorId) async {
    final v = await _service.getVendorById(vendorId);
    return v == null ? null : _modelToEntity(v);
  }

  @override
  Future<VendorEntity> create(VendorEntity entity) async {
    final m = _entityToModel(entity);
    final created = await _service.createVendor(m);
    return _modelToEntity(created);
  }

  @override
  Future<VendorEntity> update(VendorEntity entity) async {
    final m = _entityToModel(entity);
    final updated = await _service.updateVendor(m);
    return _modelToEntity(updated);
  }

  @override
  Future<void> delete(String vendorId) => _service.deleteVendor(vendorId);

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final raw = await _service.getVendorsStatistics();
    if (raw.isEmpty) return {};
    final topVendors = raw['topVendors'] as List<model.Vendor>?;
    return {
      'totalVendors': raw['totalVendors'],
      'activeVendors': raw['activeVendors'],
      'totalAmount': raw['totalAmount'],
      'totalTransactions': raw['totalTransactions'],
      if (topVendors != null) 'topVendors': topVendors.map(_modelToEntity).toList(),
    };
  }

  VendorEntity _modelToEntity(model.Vendor m) {
    return VendorEntity(
      id: m.id,
      name: m.name,
      companyName: m.companyName,
      type: _domainType(m.type),
      status: _domainStatus(m.status),
      email: m.email,
      phone: m.phone,
      address: m.address,
      taxNumber: m.taxNumber,
      commercialRegistration: m.commercialRegistration,
      contactPerson: m.contactPerson,
      bankAccount: m.bankAccount,
      notes: m.notes,
      totalSpent: m.totalSpent,
      transactionCount: m.transactionCount,
      createdAt: m.createdAt,
      updatedAt: m.updatedAt,
      lastTransactionDate: m.lastTransactionDate,
    );
  }

  model.Vendor _entityToModel(VendorEntity e) {
    return model.Vendor(
      id: e.id,
      name: e.name,
      companyName: e.companyName,
      type: _modelType(e.type),
      status: _modelStatus(e.status),
      email: e.email,
      phone: e.phone,
      address: e.address,
      taxNumber: e.taxNumber,
      commercialRegistration: e.commercialRegistration,
      contactPerson: e.contactPerson,
      bankAccount: e.bankAccount,
      notes: e.notes,
      totalSpent: e.totalSpent,
      transactionCount: e.transactionCount,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      lastTransactionDate: e.lastTransactionDate,
    );
  }

  VendorType _domainType(model.VendorType t) {
    return VendorType.values.firstWhere(
      (e) => e.name == t.name,
      orElse: () => VendorType.supplier,
    );
  }

  VendorStatus _domainStatus(model.VendorStatus s) {
    return VendorStatus.values.firstWhere(
      (e) => e.name == s.name,
      orElse: () => VendorStatus.active,
    );
  }

  model.VendorType _modelType(VendorType t) {
    return model.VendorType.values.firstWhere(
      (e) => e.name == t.name,
      orElse: () => model.VendorType.supplier,
    );
  }

  model.VendorStatus _modelStatus(VendorStatus s) {
    return model.VendorStatus.values.firstWhere(
      (e) => e.name == s.name,
      orElse: () => model.VendorStatus.active,
    );
  }
}
