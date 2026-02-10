import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// نوع المورد
enum VendorType {
  /// مورد مواد
  supplier,

  /// مقدم خدمة
  serviceProvider,

  /// مقاول
  contractor,

  /// استشاري
  consultant,

  /// أخرى
  other,
}

/// امتداد لنوع المورد
extension VendorTypeExtension on VendorType {
  /// الاسم المعروض باللغة العربية
  String get arabicName {
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

  /// الاسم المعروض باللغة الإنجليزية
  String get englishName {
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

  /// الحصول على الاسم المعروض حسب اللغة
  String getDisplayName(bool isRTL) {
    return isRTL ? arabicName : englishName;
  }

  /// الأيقونة المناسبة لكل نوع
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

  /// اللون المناسب لكل نوع
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

/// حالة المورد
enum VendorStatus {
  /// نشط
  active,

  /// غير نشط
  inactive,

  /// محظور
  blocked,
}

/// امتداد لحالة المورد
extension VendorStatusExtension on VendorStatus {
  /// الاسم المعروض باللغة العربية
  String get arabicName {
    switch (this) {
      case VendorStatus.active:
        return 'نشط';
      case VendorStatus.inactive:
        return 'غير نشط';
      case VendorStatus.blocked:
        return 'محظور';
    }
  }

  /// الاسم المعروض باللغة الإنجليزية
  String get englishName {
    switch (this) {
      case VendorStatus.active:
        return 'Active';
      case VendorStatus.inactive:
        return 'Inactive';
      case VendorStatus.blocked:
        return 'Blocked';
    }
  }

  /// الحصول على الاسم المعروض حسب اللغة
  String getDisplayName(bool isRTL) {
    return isRTL ? arabicName : englishName;
  }

  /// اللون المناسب لكل حالة
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

/// نموذج المورد
class Vendor extends HiveObject {
  String id;
  String name;
  String? companyName;
  VendorType type;
  VendorStatus status;
  String? email;
  String? phone;
  String? address;
  String? taxNumber; // الرقم الضريبي
  String? commercialRegistration; // السجل التجاري
  String? contactPerson; // الشخص المسؤول للتواصل
  String? bankAccount; // رقم الحساب البنكي
  String? notes;
  double totalSpent; // إجمالي المبلغ المصروف على هذا المورد
  int transactionCount; // عدد المعاملات
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? lastTransactionDate; // تاريخ آخر معاملة

  Vendor({
    String? id,
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
    DateTime? createdAt,
    this.updatedAt,
    this.lastTransactionDate,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'type': type.name,
      'status': status.name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'commercialRegistration': commercialRegistration,
      'contactPerson': contactPerson,
      'bankAccount': bankAccount,
      'notes': notes,
      'totalSpent': totalSpent,
      'transactionCount': transactionCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
    };
  }

  /// تحويل إلى Map (للـ Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'type': type.name,
      'status': status.name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxNumber': taxNumber,
      'commercialRegistration': commercialRegistration,
      'contactPerson': contactPerson,
      'bankAccount': bankAccount,
      'notes': notes,
      'description': notes, // alias للـ notes
      'totalAmount': totalSpent, // alias للـ totalSpent
      'totalSpent': totalSpent,
      'transactionCount': transactionCount,
      'category': type.name, // alias للـ type - تم الإصلاح
      'isActive': status == VendorStatus.active,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastTransactionDate': lastTransactionDate?.millisecondsSinceEpoch,
    };
  }

  /// إنشاء من JSON
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'],
      companyName: json['companyName'],
      type: VendorType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => VendorType.supplier,
      ),
      status: VendorStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => VendorStatus.active,
      ),
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      taxNumber: json['taxNumber'],
      commercialRegistration: json['commercialRegistration'],
      contactPerson: json['contactPerson'],
      bankAccount: json['bankAccount'],
      notes: json['notes'],
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastTransactionDate:
          json['lastTransactionDate'] != null
              ? DateTime.parse(json['lastTransactionDate'])
              : null,
    );
  }

  /// Create from API JSON response
  /// Handles API response format with _id field
  factory Vendor.fromApiJson(Map<String, dynamic> json) {
    try {
      // Handle both _id and id fields
      final id = json['id'] ?? json['_id'] ?? const Uuid().v4();

      // Parse dates (can be ISO string or DateTime)
      DateTime? parseDate(dynamic dateValue) {
        if (dateValue == null) return null;
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) {
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            debugPrint('⚠️ Error parsing date: $dateValue');
            return null;
          }
        }
        return null;
      }

      final typeString = json['type'] as String?;
      final type = VendorType.values.firstWhere(
        (t) => t.name == typeString,
        orElse: () => VendorType.supplier,
      );

      final statusString = json['status'] as String?;
      final status = VendorStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => VendorStatus.active,
      );

      return Vendor(
        id: id.toString(),
        name: json['name'] ?? 'Unknown Vendor',
        companyName: json['companyName'],
        type: type,
        status: status,
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        taxNumber: json['taxNumber'],
        commercialRegistration: json['commercialRegistration'],
        contactPerson: json['contactPerson'],
        bankAccount: json['bankAccount'],
        notes: json['notes'],
        totalSpent:
            (json['totalSpent'] is num)
                ? (json['totalSpent'] as num).toDouble()
                : 0.0,
        transactionCount:
            json['transactionCount'] is int
                ? json['transactionCount'] as int
                : 0,
        createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: parseDate(json['updatedAt']),
        lastTransactionDate: parseDate(json['lastTransactionDate']),
      );
    } catch (e) {
      debugPrint('❌ Error in Vendor.fromApiJson: $e');
      debugPrint('❌ JSON data: $json');
      return Vendor(
        name: 'Error Vendor',
        notes: 'Error parsing vendor data: $e',
      );
    }
  }

  /// إنشاء من Map (للـ Firebase)
  factory Vendor.fromMap(Map<String, dynamic> map) {
    try {
      final typeString = map['type'] as String?;
      final type = VendorType.values.firstWhere(
        (t) => t.name == typeString,
        orElse: () => VendorType.supplier,
      );

      final statusString = map['status'] as String?;
      final status = VendorStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => VendorStatus.active,
      );

      return Vendor(
        id: map['id'] ?? const Uuid().v4(),
        name: map['name'] ?? 'مورد غير معروف',
        companyName: map['companyName'],
        type: type,
        status: status,
        email: map['email'],
        phone: map['phone'],
        address: map['address'],
        taxNumber: map['taxNumber'],
        commercialRegistration: map['commercialRegistration'],
        contactPerson: map['contactPerson'],
        bankAccount: map['bankAccount'],
        notes: map['notes'] ?? map['description'],
        totalSpent:
            (map['totalAmount'] ?? map['totalSpent'])?.toDouble() ?? 0.0,
        transactionCount: map['transactionCount'] ?? 0,
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(map['updatedAt']),
        lastTransactionDate: _parseDateTime(map['lastTransactionDate']),
      );
    } catch (e) {
      debugPrint('❌ خطأ في Vendor.fromMap: $e');
      return Vendor(name: 'مورد خطأ', notes: 'حدث خطأ في قراءة بيانات المورد');
    }
  }

  /// Helper method لتحويل Timestamp أو int إلى DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.tryParse(value);
    }

    // إذا كان Firestore Timestamp
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (e) {
      debugPrint('❌ خطأ في تحويل التاريخ: $value');
      return null;
    }
  }

  /// نسخة محدثة من المورد
  Vendor copyWith({
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
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      type: type ?? this.type,
      status: status ?? this.status,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxNumber: taxNumber ?? this.taxNumber,
      commercialRegistration:
          commercialRegistration ?? this.commercialRegistration,
      contactPerson: contactPerson ?? this.contactPerson,
      bankAccount: bankAccount ?? this.bankAccount,
      notes: notes ?? this.notes,
      totalSpent: totalSpent ?? this.totalSpent,
      transactionCount: transactionCount ?? this.transactionCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }

  // Helper getters

  /// alias للـ notes (للتوافق مع Firebase)
  String? get description => notes;

  /// alias للـ totalSpent (للتوافق مع Firebase)
  double get totalAmount => totalSpent;

  /// alias للـ type (للتوافق مع Firebase)
  VendorType get category => type;

  /// هل المورد نشط؟
  bool get isActive => status == VendorStatus.active;

  /// هل المورد محظور؟
  bool get isBlocked => status == VendorStatus.blocked;

  /// متوسط قيمة المعاملة
  double get averageTransactionValue {
    if (transactionCount == 0) return 0.0;
    return totalSpent / transactionCount;
  }

  /// عدد الأيام منذ آخر معاملة
  int? get daysSinceLastTransaction {
    if (lastTransactionDate == null) return null;
    return DateTime.now().difference(lastTransactionDate!).inDays;
  }

  /// هل المورد غير نشط لفترة طويلة؟
  bool get isInactiveForLong {
    final days = daysSinceLastTransaction;
    return days != null && days > 90; // أكثر من 90 يوم
  }

  /// الاسم المعروض (يفضل اسم الشركة إن وجد)
  String get displayName {
    return companyName?.isNotEmpty == true ? companyName! : name;
  }

  /// معلومات المورد للعرض
  String getVendorInfo(bool isRTL) {
    final typeName = type.getDisplayName(isRTL);
    final statusName = status.getDisplayName(isRTL);
    return '$typeName - $statusName';
  }

  /// معلومات الاتصال
  String? get contactInfo {
    final List<String> contacts = [];
    if (email?.isNotEmpty == true) contacts.add(email!);
    if (phone?.isNotEmpty == true) contacts.add(phone!);
    return contacts.isEmpty ? null : contacts.join(' • ');
  }

  @override
  String toString() {
    return 'Vendor(id: $id, name: $name, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vendor && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

/// Hive Adapter للمورد
class VendorAdapter extends TypeAdapter<Vendor> {
  @override
  final int typeId = 4; // تأكد من أن هذا الرقم فريد

  @override
  Vendor read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final name = reader.readString();
      final hasCompanyName = reader.readBool();
      final companyName = hasCompanyName ? reader.readString() : null;
      final typeString = reader.readString();
      final type = VendorType.values.firstWhere(
        (t) => t.name == typeString,
        orElse: () => VendorType.supplier,
      );
      final statusString = reader.readString();
      final status = VendorStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => VendorStatus.active,
      );
      final hasEmail = reader.readBool();
      final email = hasEmail ? reader.readString() : null;
      final hasPhone = reader.readBool();
      final phone = hasPhone ? reader.readString() : null;
      final hasAddress = reader.readBool();
      final address = hasAddress ? reader.readString() : null;
      final hasTaxNumber = reader.readBool();
      final taxNumber = hasTaxNumber ? reader.readString() : null;
      final hasCommercialRegistration = reader.readBool();
      final commercialRegistration =
          hasCommercialRegistration ? reader.readString() : null;
      final hasContactPerson = reader.readBool();
      final contactPerson = hasContactPerson ? reader.readString() : null;
      final hasBankAccount = reader.readBool();
      final bankAccount = hasBankAccount ? reader.readString() : null;
      final hasNotes = reader.readBool();
      final notes = hasNotes ? reader.readString() : null;
      final totalSpent = reader.readDouble();
      final transactionCount = reader.readInt();
      final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final hasUpdatedAt = reader.readBool();
      final updatedAt =
          hasUpdatedAt
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null;
      final hasLastTransactionDate = reader.readBool();
      final lastTransactionDate =
          hasLastTransactionDate
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null;

      return Vendor(
        id: id,
        name: name,
        companyName: companyName,
        type: type,
        status: status,
        email: email,
        phone: phone,
        address: address,
        taxNumber: taxNumber,
        commercialRegistration: commercialRegistration,
        contactPerson: contactPerson,
        bankAccount: bankAccount,
        notes: notes,
        totalSpent: totalSpent,
        transactionCount: transactionCount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastTransactionDate: lastTransactionDate,
      );
    } catch (e) {
      // في حالة الخطأ، أعد مورد افتراضي
      return Vendor(name: 'مورد خطأ', notes: 'حدث خطأ في قراءة بيانات المورد');
    }
  }

  @override
  void write(BinaryWriter writer, Vendor obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeBool(obj.companyName != null);
    if (obj.companyName != null) {
      writer.writeString(obj.companyName!);
    }
    writer.writeString(obj.type.name);
    writer.writeString(obj.status.name);
    writer.writeBool(obj.email != null);
    if (obj.email != null) {
      writer.writeString(obj.email!);
    }
    writer.writeBool(obj.phone != null);
    if (obj.phone != null) {
      writer.writeString(obj.phone!);
    }
    writer.writeBool(obj.address != null);
    if (obj.address != null) {
      writer.writeString(obj.address!);
    }
    writer.writeBool(obj.taxNumber != null);
    if (obj.taxNumber != null) {
      writer.writeString(obj.taxNumber!);
    }
    writer.writeBool(obj.commercialRegistration != null);
    if (obj.commercialRegistration != null) {
      writer.writeString(obj.commercialRegistration!);
    }
    writer.writeBool(obj.contactPerson != null);
    if (obj.contactPerson != null) {
      writer.writeString(obj.contactPerson!);
    }
    writer.writeBool(obj.bankAccount != null);
    if (obj.bankAccount != null) {
      writer.writeString(obj.bankAccount!);
    }
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) {
      writer.writeString(obj.notes!);
    }
    writer.writeDouble(obj.totalSpent);
    writer.writeInt(obj.transactionCount);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.updatedAt != null);
    if (obj.updatedAt != null) {
      writer.writeInt(obj.updatedAt!.millisecondsSinceEpoch);
    }
    writer.writeBool(obj.lastTransactionDate != null);
    if (obj.lastTransactionDate != null) {
      writer.writeInt(obj.lastTransactionDate!.millisecondsSinceEpoch);
    }
  }
}
