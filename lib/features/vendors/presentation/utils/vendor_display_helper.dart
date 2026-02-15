import 'package:flutter/material.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';

/// Display and UI helpers for domain vendor types/status/entity (presentation only).
extension VendorEntityDisplay on VendorEntity {
  String get displayName => companyName?.isNotEmpty == true ? companyName! : name;

  String? get contactInfo {
    final parts = <String>[];
    if (email?.isNotEmpty == true) parts.add(email!);
    if (phone?.isNotEmpty == true) parts.add(phone!);
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  double get averageTransactionValue =>
      transactionCount > 0 ? totalSpent / transactionCount : 0.0;

  int? get daysSinceLastTransaction {
    if (lastTransactionDate == null) return null;
    return DateTime.now().difference(lastTransactionDate!).inDays;
  }
}

extension VendorTypeDisplay on VendorType {
  String displayName(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case VendorType.supplier:
          return 'مورد مواد';
        case VendorType.serviceProvider:
          return 'مقدم خدمة';
        case VendorType.contractor:
          return 'مقاول';
        case VendorType.consultant:
          return 'استشاري';
        case VendorType.other:
          return 'أخرى';
      }
    }
    switch (this) {
      case VendorType.supplier:
        return 'Supplier';
      case VendorType.serviceProvider:
        return 'Service Provider';
      case VendorType.contractor:
        return 'Contractor';
      case VendorType.consultant:
        return 'Consultant';
      case VendorType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case VendorType.supplier:
        return Icons.inventory;
      case VendorType.serviceProvider:
        return Icons.build;
      case VendorType.contractor:
        return Icons.construction;
      case VendorType.consultant:
        return Icons.psychology;
      case VendorType.other:
        return Icons.business;
    }
  }

  Color get color {
    switch (this) {
      case VendorType.supplier:
        return Colors.blue;
      case VendorType.serviceProvider:
        return Colors.green;
      case VendorType.contractor:
        return Colors.orange;
      case VendorType.consultant:
        return Colors.purple;
      case VendorType.other:
        return Colors.grey;
    }
  }
}

extension VendorStatusDisplay on VendorStatus {
  String displayName(bool isRTL) {
    if (isRTL) {
      switch (this) {
        case VendorStatus.active:
          return 'نشط';
        case VendorStatus.inactive:
          return 'غير نشط';
        case VendorStatus.blocked:
          return 'محظور';
      }
    }
    switch (this) {
      case VendorStatus.active:
        return 'Active';
      case VendorStatus.inactive:
        return 'Inactive';
      case VendorStatus.blocked:
        return 'Blocked';
    }
  }

  Color get color {
    switch (this) {
      case VendorStatus.active:
        return Colors.green;
      case VendorStatus.inactive:
        return Colors.grey;
      case VendorStatus.blocked:
        return Colors.red;
    }
  }
}
