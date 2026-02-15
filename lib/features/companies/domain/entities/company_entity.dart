import 'package:expense_tracker/features/companies/domain/entities/owner_info_entity.dart';

/// Pure domain entity for a company (no data-layer or UI dependencies).
class CompanyEntity {
  final String id;
  final String name;
  final String? taxNumber;
  final String? address;
  final String? phone;
  final String currency;
  final String fiscalYearStart;
  final bool isActive;
  final int employeeCount;
  final int currentEmployeeCount;
  final String ownerEmail;
  final OwnerInfoEntity? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyEntity({
    required this.id,
    required this.name,
    this.taxNumber,
    this.address,
    this.phone,
    required this.currency,
    this.fiscalYearStart = '01-01',
    this.isActive = true,
    this.employeeCount = 0,
    this.currentEmployeeCount = 0,
    required this.ownerEmail,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  CompanyEntity copyWith({
    String? id,
    String? name,
    String? taxNumber,
    String? address,
    String? phone,
    String? currency,
    String? fiscalYearStart,
    bool? isActive,
    int? employeeCount,
    int? currentEmployeeCount,
    String? ownerEmail,
    OwnerInfoEntity? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      taxNumber: taxNumber ?? this.taxNumber,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      isActive: isActive ?? this.isActive,
      employeeCount: employeeCount ?? this.employeeCount,
      currentEmployeeCount: currentEmployeeCount ?? this.currentEmployeeCount,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
