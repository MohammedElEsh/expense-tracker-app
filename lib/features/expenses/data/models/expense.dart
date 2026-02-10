// ✅ Clean Architecture - Data Models Layer
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';

class Expense extends HiveObject {
  String id;
  double amount;
  String category;
  String? customCategory; // فئة مخصصة عندما تكون category == "أخرى"
  String notes;
  DateTime date;
  String? photoPath; // مسار الصورة المرفقة (اختياري)
  String accountId; // معرف الحساب المرتبط بالمصروف
  AppMode appMode; // نوع الوضع (شخصي أو تجاري)

  // الحقول التجارية الجديدة
  String? projectId; // معرف المشروع (اختياري)
  String? department; // القسم (اختياري)
  String? invoiceNumber; // رقم الفاتورة (اختياري)
  String? vendorName; // اسم المورد (اختياري)
  String? employeeId; // معرف الموظف الذي أنفق (اختياري)

  // اسم الموظف (من الـ API)
  final String? employeeName;

  // Display category (from API response, falls back to category or customCategory)
  String? displayCategory;

  // API timestamps (read-only, set by server)
  DateTime? createdAt; // تاريخ الإنشاء من API
  DateTime? updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.customCategory,
    required this.notes,
    required this.date,
    required this.accountId,
    required this.appMode,
    this.photoPath,
    this.projectId,
    this.department,
    this.invoiceNumber,
    this.vendorName,
    this.employeeId,
    this.employeeName,
    this.displayCategory,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'customCategory': customCategory,
      'notes': notes,
      'date': date.toIso8601String(),
      'photoPath': photoPath,
      'accountId': accountId,
      'appMode': appMode.name,
      'projectId': projectId,
      'department': department,
      'invoiceNumber': invoiceNumber,
      'vendorName': vendorName,
      'employeeId': employeeId,
      'employeeName': employeeName, // 👈 جديد
      'displayCategory': displayCategory,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      customCategory: json['customCategory'],
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      photoPath: json['photoPath'],
      accountId: json['accountId'] ?? '', // احتياطي للبيانات القديمة
      appMode: AppMode.values.firstWhere(
        (mode) => mode.name == json['appMode'],
        orElse: () => AppMode.personal, // افتراضي للبيانات القديمة
      ),
      projectId: json['projectId'],
      department: json['department'],
      invoiceNumber: json['invoiceNumber'],
      vendorName: json['vendorName'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'], // 👈 جديد
      displayCategory: json['displayCategory'],
    );
  }

  /// Parse expense from API response
  /// Handles accountId and projectId as objects or strings
  factory Expense.fromApiJson(Map<String, dynamic> json) {
    // Handle accountId - can be object or string
    String accountId = '';
    if (json['accountId'] != null) {
      if (json['accountId'] is Map) {
        // API returns accountId as object with _id field
        accountId = json['accountId']['_id'] ?? json['accountId']['id'] ?? '';
      } else if (json['accountId'] is String) {
        accountId = json['accountId'];
      }
    }

    // Handle projectId - can be object or string
    String? projectId;
    if (json['projectId'] != null) {
      if (json['projectId'] is Map) {
        // API returns projectId as object with _id field
        projectId = json['projectId']['_id'] ?? json['projectId']['id'];
      } else if (json['projectId'] is String) {
        projectId = json['projectId'];
      }
    }

    // Handle employeeId / employeeName - can be object or string
    String? employeeId;
    String? employeeName;
    if (json['employeeId'] != null) {
      if (json['employeeId'] is Map) {
        final emp = json['employeeId'] as Map<String, dynamic>;
        // API returns employeeId as object with _id field
        employeeId = emp['_id'] ?? emp['id'];
        employeeName = emp['name']; // 👈 هنا بنجيب الاسم
      } else if (json['employeeId'] is String) {
        employeeId = json['employeeId'];
      }
    }

    // Handle date parsing - can be ISO string or DateTime
    // Convert to local time to ensure correct display
    // Note: expense.date is the expense date (often midnight UTC), not creation time
    DateTime expenseDate;
    try {
      if (json['date'] is String) {
        final rawValue = json['date'] as String;
        final parsed = DateTime.parse(rawValue);
        // If string ends with 'Z', it's UTC - convert to local
        expenseDate =
            rawValue.endsWith('Z')
                ? parsed.toLocal()
                : (parsed.isUtc ? parsed.toLocal() : parsed);
      } else if (json['date'] is int) {
        expenseDate =
            DateTime.fromMillisecondsSinceEpoch(
              json['date'],
              isUtc: true,
            ).toLocal();
      } else {
        expenseDate = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Error parsing date: ${json['date']} - $e');
      expenseDate = DateTime.now();
    }

    // Handle appMode - can be string or missing (default to personal)
    AppMode appMode = AppMode.personal;
    if (json['appMode'] != null) {
      try {
        appMode = AppMode.values.firstWhere(
          (mode) => mode.name == json['appMode'],
          orElse: () => AppMode.personal,
        );
      } catch (e) {
        appMode = AppMode.personal;
      }
    }

    // Parse createdAt and updatedAt timestamps from API
    // Ensure UTC timestamps (ending with 'Z') are properly converted to local time
    DateTime? createdAt;
    DateTime? updatedAt;

    try {
      if (json['createdAt'] != null) {
        if (json['createdAt'] is String) {
          final rawValue = json['createdAt'] as String;
          final parsed = DateTime.parse(rawValue);
          // If string ends with 'Z', it's UTC - convert to local
          createdAt =
              rawValue.endsWith('Z')
                  ? parsed.toLocal()
                  : (parsed.isUtc ? parsed.toLocal() : parsed);

          // Debug logging for timezone handling
          debugPrint('🔍 Expense.fromApiJson - createdAt parsing:');
          debugPrint('   Raw API: $rawValue');
          debugPrint('   Parsed (UTC): ${parsed.toUtc()}');
          debugPrint('   Final (Local): $createdAt');
        } else if (json['createdAt'] is int) {
          createdAt =
              DateTime.fromMillisecondsSinceEpoch(
                json['createdAt'],
                isUtc: true,
              ).toLocal();
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing createdAt: ${json['createdAt']} - $e');
    }

    try {
      if (json['updatedAt'] != null) {
        if (json['updatedAt'] is String) {
          final rawValue = json['updatedAt'] as String;
          final parsed = DateTime.parse(rawValue);
          // If string ends with 'Z', it's UTC - convert to local
          updatedAt =
              rawValue.endsWith('Z')
                  ? parsed.toLocal()
                  : (parsed.isUtc ? parsed.toLocal() : parsed);
        } else if (json['updatedAt'] is int) {
          updatedAt =
              DateTime.fromMillisecondsSinceEpoch(
                json['updatedAt'],
                isUtc: true,
              ).toLocal();
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing updatedAt: ${json['updatedAt']} - $e');
    }

    // Ensure required fields have valid defaults
    final expenseId = json['_id'] ?? json['id'] ?? '';
    final expenseAmount = (json['amount'] ?? 0.0).toDouble();
    final expenseCategory = json['category'] ?? '';
    final expenseNotes = json['notes'] ?? '';

    if (expenseId.isEmpty) {
      debugPrint(
        '⚠️ Expense.fromApiJson - Missing expense ID, generating new one',
      );
    }
    if (expenseAmount == 0.0) {
      debugPrint('⚠️ Expense.fromApiJson - Expense amount is 0');
    }
    if (expenseCategory.isEmpty) {
      debugPrint('⚠️ Expense.fromApiJson - Missing category');
    }

    final expense = Expense(
      id:
          expenseId.isEmpty
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : expenseId,
      amount: expenseAmount,
      category: expenseCategory.isEmpty ? 'Other' : expenseCategory,
      customCategory: json['customCategory'],
      notes: expenseNotes,
      date: expenseDate,
      photoPath: json['photoPath'],
      accountId:
          accountId.isEmpty
              ? 'default'
              : accountId, // Ensure accountId is not empty
      appMode: appMode,
      projectId: projectId,
      department: json['department'],
      invoiceNumber: json['invoiceNumber'],
      vendorName: json['vendorName'],
      employeeId: employeeId,
      employeeName: employeeName, // 👈 هنا بنمرر الاسم للموديل
      displayCategory: json['displayCategory'],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    debugPrint(
      '✅ Expense.fromApiJson - Parsed expense: '
      'id=${expense.id}, amount=${expense.amount}, '
      'category=${expense.category}, accountId=${expense.accountId}, '
      'employeeId=${expense.employeeId}, employeeName=${expense.employeeName}',
    );

    return expense;
  }

  // نسخة محدثة من المصروف
  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? customCategory,
    String? notes,
    DateTime? date,
    String? photoPath,
    String? accountId,
    AppMode? appMode,
    String? projectId,
    String? department,
    String? invoiceNumber,
    String? vendorName,
    String? employeeId,
    String? employeeName,
    String? displayCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      accountId: accountId ?? this.accountId,
      appMode: appMode ?? this.appMode,
      projectId: projectId ?? this.projectId,
      department: department ?? this.department,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      vendorName: vendorName ?? this.vendorName,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      displayCategory: displayCategory ?? this.displayCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the display category name
  /// Returns displayCategory if available, otherwise customCategory if available, otherwise category
  String getDisplayCategoryName() {
    return displayCategory ?? customCategory ?? category;
  }
}

// Manual Hive Adapter - No code generation needed!
class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final amount = reader.readDouble();
      final category = reader.readString();
      final notes = reader.readString();
      final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final hasPhoto = reader.readBool();
      final photoPath = hasPhoto ? reader.readString() : null;

      // التحقق من وجود accountId (للتوافق مع البيانات القديمة)
      String accountId = '';
      try {
        accountId = reader.readString();
      } catch (e) {
        // إذا لم يوجد accountId في البيانات القديمة، استخدم قيمة افتراضية
        accountId = 'default_cash_account';
      }

      // قراءة appMode (اختياري للتوافق مع البيانات القديمة)
      AppMode appMode = AppMode.personal;
      try {
        final appModeString = reader.readString();
        appMode = AppMode.values.firstWhere(
          (mode) => mode.name == appModeString,
          orElse: () => AppMode.personal,
        );
      } catch (e) {
        // إذا لم يوجد appMode في البيانات القديمة، استخدم الوضع الشخصي
        appMode = AppMode.personal;
      }

      // قراءة الحقول التجارية الجديدة (اختيارية للتوافق مع البيانات القديمة)
      String? projectId;
      String? department;
      String? invoiceNumber;
      String? vendorName;
      String? employeeId;
      String? employeeName;

      try {
        final hasProjectId = reader.readBool();
        projectId = hasProjectId ? reader.readString() : null;

        final hasDepartment = reader.readBool();
        department = hasDepartment ? reader.readString() : null;

        final hasInvoiceNumber = reader.readBool();
        invoiceNumber = hasInvoiceNumber ? reader.readString() : null;

        final hasVendorName = reader.readBool();
        vendorName = hasVendorName ? reader.readString() : null;

        final hasEmployeeId = reader.readBool();
        employeeId = hasEmployeeId ? reader.readString() : null;

        final hasEmployeeName = reader.readBool();
        employeeName = hasEmployeeName ? reader.readString() : null;
      } catch (e) {
        // إذا لم توجد الحقول الجديدة، اتركها null
      }

      return Expense(
        id: id,
        amount: amount,
        category: category,
        notes: notes,
        date: date,
        photoPath: photoPath,
        accountId: accountId,
        appMode: appMode,
        projectId: projectId,
        department: department,
        invoiceNumber: invoiceNumber,
        vendorName: vendorName,
        employeeId: employeeId,
        employeeName: employeeName,
      );
    } catch (e) {
      // في حالة الخطأ، أعد بيانات افتراضية
      return Expense(
        id: 'error_expense',
        amount: 0.0,
        category: 'Others',
        notes: 'خطأ في قراءة البيانات',
        date: DateTime.now(),
        accountId: 'default_cash_account',
        appMode: AppMode.personal,
      );
    }
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeDouble(obj.amount);
    writer.writeString(obj.category);
    writer.writeString(obj.notes);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.photoPath != null);
    if (obj.photoPath != null) {
      writer.writeString(obj.photoPath!);
    }
    writer.writeString(obj.accountId);
    writer.writeString(obj.appMode.name);

    // كتابة الحقول التجارية الجديدة
    writer.writeBool(obj.projectId != null);
    if (obj.projectId != null) {
      writer.writeString(obj.projectId!);
    }

    writer.writeBool(obj.department != null);
    if (obj.department != null) {
      writer.writeString(obj.department!);
    }

    writer.writeBool(obj.invoiceNumber != null);
    if (obj.invoiceNumber != null) {
      writer.writeString(obj.invoiceNumber!);
    }

    writer.writeBool(obj.vendorName != null);
    if (obj.vendorName != null) {
      writer.writeString(obj.vendorName!);
    }

    writer.writeBool(obj.employeeId != null);
    if (obj.employeeId != null) {
      writer.writeString(obj.employeeId!);
    }

    writer.writeBool(obj.employeeName != null);
    if (obj.employeeName != null) {
      writer.writeString(obj.employeeName!);
    }
  }
}
