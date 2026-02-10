import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// حالة المشروع
enum ProjectStatus {
  /// قيد التخطيط
  planning,

  /// نشط
  active,

  /// معلق
  onHold,

  /// مكتمل
  completed,

  /// ملغي
  cancelled,
}

/// امتداد لحالة المشروع
extension ProjectStatusExtension on ProjectStatus {
  /// الاسم المعروض باللغة العربية
  String get arabicName {
    switch (this) {
      case ProjectStatus.planning:
        return 'قيد التخطيط';
      case ProjectStatus.active:
        return 'نشط';
      case ProjectStatus.onHold:
        return 'معلق';
      case ProjectStatus.completed:
        return 'مكتمل';
      case ProjectStatus.cancelled:
        return 'ملغي';
    }
  }

  /// الاسم المعروض باللغة الإنجليزية
  String get englishName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// الحصول على الاسم المعروض حسب اللغة
  String getDisplayName(bool isRTL) {
    return isRTL ? arabicName : englishName;
  }

  /// اللون المناسب لكل حالة
  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.grey;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  /// الأيقونة المناسبة لكل حالة
  IconData get icon {
    switch (this) {
      case ProjectStatus.planning:
        return Icons.schedule;
      case ProjectStatus.active:
        return Icons.play_circle;
      case ProjectStatus.onHold:
        return Icons.pause_circle;
      case ProjectStatus.completed:
        return Icons.check_circle;
      case ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// نموذج المشروع
class Project extends HiveObject {
  String id;
  String name;
  String? description;
  ProjectStatus status;
  DateTime startDate;
  DateTime? endDate;
  double budget;
  double spentAmount;
  String? managerName; // اسم مدير المشروع
  String? clientName; // اسم العميل
  int priority; // الأولوية (1-5)
  DateTime createdAt;
  DateTime? updatedAt;

  Project({
    String? id,
    required this.name,
    this.description,
    this.status = ProjectStatus.planning,
    DateTime? startDate,
    this.endDate,
    this.budget = 0.0,
    this.spentAmount = 0.0,
    this.managerName,
    this.clientName,
    this.priority = 3,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       startDate = startDate ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'budget': budget,
      'spentAmount': spentAmount,
      'managerName': managerName,
      'clientName': clientName,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// تحويل إلى Map (للـ Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'budget': budget,
      'spent': spentAmount, // استخدام 'spent' للـ Firebase
      'spentAmount': spentAmount,
      'managerName': managerName,
      'clientName': clientName,
      'priority': priority,
      'isActive':
          status == ProjectStatus.active || status == ProjectStatus.planning,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// إنشاء من JSON
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ProjectStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      budget: json['budget']?.toDouble() ?? 0.0,
      spentAmount: json['spentAmount']?.toDouble() ?? 0.0,
      managerName: json['managerName'],
      clientName: json['clientName'],
      priority: json['priority'] ?? 3,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  /// إنشاء من JSON الخاص بالـ API (مع _id من MongoDB)
  factory Project.fromApiJson(Map<String, dynamic> json) {
    try {
      // Handle _id from MongoDB
      final id =
          json['_id']?.toString() ??
          json['id']?.toString() ??
          const Uuid().v4();

      // Parse status - API returns lowercase string
      final statusString = json['status']?.toString().toLowerCase();
      final status = ProjectStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == statusString,
        orElse: () => ProjectStatus.planning,
      );

      // Parse dates - API returns ISO8601 strings
      DateTime startDate = DateTime.now();
      if (json['startDate'] != null) {
        startDate =
            DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now();
      }

      DateTime? endDate;
      if (json['endDate'] != null) {
        endDate = DateTime.tryParse(json['endDate'].toString());
      }

      DateTime createdAt = DateTime.now();
      if (json['createdAt'] != null) {
        createdAt =
            DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
      }

      DateTime? updatedAt;
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.tryParse(json['updatedAt'].toString());
      }

      return Project(
        id: id,
        name: json['name']?.toString() ?? 'مشروع غير معروف',
        description: json['description']?.toString(),
        status: status,
        startDate: startDate,
        endDate: endDate,
        budget: (json['budget'] ?? 0).toDouble(),
        spentAmount: (json['spentAmount'] ?? json['spent'] ?? 0).toDouble(),
        managerName: json['managerName']?.toString(),
        clientName: json['clientName']?.toString(),
        priority: json['priority'] ?? 3,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      debugPrint('❌ خطأ في Project.fromApiJson: $e');
      return Project(
        name: 'مشروع خطأ',
        description: 'حدث خطأ في قراءة بيانات المشروع',
      );
    }
  }

  /// تحويل إلى JSON للـ API
  Map<String, dynamic> toApiJson() {
    return {
      'name': name,
      'description': description,
      'status': status.name,
      'startDate': startDate.toIso8601String().split('T').first,
      'endDate': endDate?.toIso8601String().split('T').first,
      'budget': budget,
      'managerName': managerName,
      'clientName': clientName,
      'priority': priority,
    };
  }

  /// إنشاء من Map (للـ Firebase)
  factory Project.fromMap(Map<String, dynamic> map) {
    try {
      final statusString = map['status'] as String?;
      final status = ProjectStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => ProjectStatus.planning,
      );

      return Project(
        id: map['id'] ?? const Uuid().v4(),
        name: map['name'] ?? 'مشروع غير معروف',
        description: map['description'],
        status: status,
        startDate: _parseDateTime(map['startDate']) ?? DateTime.now(),
        endDate: _parseDateTime(map['endDate']),
        budget: map['budget']?.toDouble() ?? 0.0,
        spentAmount: (map['spent'] ?? map['spentAmount'])?.toDouble() ?? 0.0,
        managerName: map['managerName'],
        clientName: map['clientName'],
        priority: map['priority'] ?? 3,
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(map['updatedAt']),
      );
    } catch (e) {
      debugPrint('❌ خطأ في Project.fromMap: $e');
      return Project(
        name: 'مشروع خطأ',
        description: 'حدث خطأ في قراءة بيانات المشروع',
      );
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

  /// نسخة محدثة من المشروع
  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? spentAmount,
    String? managerName,
    String? clientName,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      spentAmount: spentAmount ?? this.spentAmount,
      managerName: managerName ?? this.managerName,
      clientName: clientName ?? this.clientName,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper getters

  /// alias للـ spentAmount (للتوافق مع Firebase)
  double get spent => spentAmount;

  /// الميزانية المتبقية
  double get remainingBudget => budget - spentAmount;

  /// نسبة الإنفاق
  double get spentPercentage => budget > 0 ? (spentAmount / budget) * 100 : 0.0;

  /// هل تجاوز الميزانية؟
  bool get isOverBudget => spentAmount > budget;

  /// هل اقترب من انتهاء الميزانية؟
  bool get isNearBudgetLimit => spentPercentage >= 80 && !isOverBudget;

  /// مدة المشروع بالأيام
  int? get durationInDays {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays;
  }

  /// الأيام المتبقية
  int? get remainingDays {
    if (endDate == null || status == ProjectStatus.completed) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  /// هل المشروع متأخر؟
  bool get isOverdue {
    if (endDate == null || status == ProjectStatus.completed) return false;
    return DateTime.now().isAfter(endDate!);
  }

  /// هل المشروع نشط؟
  bool get isActive => status == ProjectStatus.active;

  /// هل المشروع مكتمل؟
  bool get isCompleted => status == ProjectStatus.completed;

  /// معلومات المشروع للعرض
  String getProjectInfo(bool isRTL) {
    final statusName = status.getDisplayName(isRTL);
    final budgetInfo =
        isRTL
            ? 'الميزانية: ${budget.toStringAsFixed(2)}'
            : 'Budget: ${budget.toStringAsFixed(2)}';
    return '$statusName - $budgetInfo';
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, status: $status, budget: $budget)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

/// Hive Adapter للمشروع
class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 3; // تأكد من أن هذا الرقم فريد

  @override
  Project read(BinaryReader reader) {
    try {
      final id = reader.readString();
      final name = reader.readString();
      final hasDescription = reader.readBool();
      final description = hasDescription ? reader.readString() : null;
      final statusString = reader.readString();
      final status = ProjectStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => ProjectStatus.planning,
      );
      final startDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final hasEndDate = reader.readBool();
      final endDate =
          hasEndDate
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null;
      final budget = reader.readDouble();
      final spentAmount = reader.readDouble();
      final hasManagerName = reader.readBool();
      final managerName = hasManagerName ? reader.readString() : null;
      final hasClientName = reader.readBool();
      final clientName = hasClientName ? reader.readString() : null;
      final priority = reader.readInt();
      final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final hasUpdatedAt = reader.readBool();
      final updatedAt =
          hasUpdatedAt
              ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
              : null;

      return Project(
        id: id,
        name: name,
        description: description,
        status: status,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        spentAmount: spentAmount,
        managerName: managerName,
        clientName: clientName,
        priority: priority,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      // في حالة الخطأ، أعد مشروع افتراضي
      return Project(
        name: 'مشروع خطأ',
        description: 'حدث خطأ في قراءة بيانات المشروع',
      );
    }
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeBool(obj.description != null);
    if (obj.description != null) {
      writer.writeString(obj.description!);
    }
    writer.writeString(obj.status.name);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeBool(obj.endDate != null);
    if (obj.endDate != null) {
      writer.writeInt(obj.endDate!.millisecondsSinceEpoch);
    }
    writer.writeDouble(obj.budget);
    writer.writeDouble(obj.spentAmount);
    writer.writeBool(obj.managerName != null);
    if (obj.managerName != null) {
      writer.writeString(obj.managerName!);
    }
    writer.writeBool(obj.clientName != null);
    if (obj.clientName != null) {
      writer.writeString(obj.clientName!);
    }
    writer.writeInt(obj.priority);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.updatedAt != null);
    if (obj.updatedAt != null) {
      writer.writeInt(obj.updatedAt!.millisecondsSinceEpoch);
    }
  }
}
