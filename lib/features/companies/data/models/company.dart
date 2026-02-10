import 'package:flutter/material.dart';

/// Company model representing a business company
class Company {
  final String id;
  final String name;
  final String? taxNumber;
  final String? address;
  final String? phone;
  final String currency;
  final String fiscalYearStart; // Format: "MM-DD"
  final bool isActive;
  final int employeeCount;
  final int currentEmployeeCount;
  final String ownerEmail;
  final OwnerInfo? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Company({
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

  /// Create from API JSON response
  factory Company.fromApiJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';

      // Parse owner info
      OwnerInfo? ownerInfo;
      if (json['ownerId'] != null && json['ownerId'] is Map) {
        final ownerData = json['ownerId'] as Map<String, dynamic>;
        ownerInfo = OwnerInfo(
          id: ownerData['_id']?.toString() ?? ownerData['id']?.toString() ?? '',
          name: ownerData['name']?.toString() ?? '',
          email: ownerData['email']?.toString() ?? '',
          phone: ownerData['phone']?.toString(),
        );
      }

      // Parse dates
      DateTime createdAt = DateTime.now();
      if (json['createdAt'] != null) {
        createdAt = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
      }

      DateTime updatedAt = DateTime.now();
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now();
      }

      return Company(
        id: id,
        name: json['name']?.toString() ?? '',
        taxNumber: json['taxNumber']?.toString(),
        address: json['address']?.toString(),
        phone: json['phone']?.toString(),
        currency: json['currency']?.toString() ?? 'SAR',
        fiscalYearStart: json['fiscalYearStart']?.toString() ?? '01-01',
        isActive: json['isActive'] as bool? ?? true,
        employeeCount: (json['employeeCount'] ?? 0) as int,
        currentEmployeeCount: (json['currentEmployeeCount'] ?? json['employeeCount'] ?? 0) as int,
        ownerEmail: json['ownerEmail']?.toString() ?? '',
        ownerId: ownerInfo,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      debugPrint('❌ Error parsing Company from JSON: $e');
      rethrow;
    }
  }

  /// Convert to API JSON for POST/PUT requests
  Map<String, dynamic> toApiJson() {
    final json = <String, dynamic>{
      'name': name,
      'currency': currency,
    };

    if (taxNumber != null && taxNumber!.isNotEmpty) {
      json['taxNumber'] = taxNumber;
    }
    if (address != null && address!.isNotEmpty) {
      json['address'] = address;
    }
    if (phone != null && phone!.isNotEmpty) {
      json['phone'] = phone;
    }

    return json;
  }

  /// Create a copy with updated fields
  Company copyWith({
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
    OwnerInfo? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
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
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Company && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Owner information nested in Company
class OwnerInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;

  OwnerInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

