import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';

/// Pure domain entity for a vendor (no data-layer or UI dependencies).
class VendorEntity {
  final String id;
  final String name;
  final String? companyName;
  final VendorType type;
  final VendorStatus status;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final String? commercialRegistration;
  final String? contactPerson;
  final String? bankAccount;
  final String? notes;
  final double totalSpent;
  final int transactionCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastTransactionDate;

  const VendorEntity({
    required this.id,
    required this.name,
    this.companyName,
    this.type = VendorType.supplier,
    this.status = VendorStatus.active,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.commercialRegistration,
    this.contactPerson,
    this.bankAccount,
    this.notes,
    this.totalSpent = 0.0,
    this.transactionCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.lastTransactionDate,
  });

  VendorEntity copyWith({
    String? id,
    String? name,
    String? companyName,
    VendorType? type,
    VendorStatus? status,
    String? email,
    String? phone,
    String? address,
    String? taxNumber,
    String? commercialRegistration,
    String? contactPerson,
    String? bankAccount,
    String? notes,
    double? totalSpent,
    int? transactionCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastTransactionDate,
  }) {
    return VendorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      status: status ?? this.status,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      commercialRegistration: commercialRegistration ?? this.commercialRegistration,
      contactPerson: contactPerson ?? this.contactPerson,
      bankAccount: bankAccount ?? this.bankAccount,
      notes: notes ?? this.notes,
      totalSpent: totalSpent ?? this.totalSpent,
      transactionCount: transactionCount ?? this.transactionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }

  bool get isActive => status == VendorStatus.active;
}
