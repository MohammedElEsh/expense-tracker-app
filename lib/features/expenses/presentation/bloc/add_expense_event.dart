// Add Expense - BLoC Events
import 'package:equatable/equatable.dart';

abstract class AddExpenseEvent extends Equatable {
  const AddExpenseEvent();

  @override
  List<Object?> get props => [];
}

// تغيير القيمة
class ChangeAmountEvent extends AddExpenseEvent {
  final double amount;

  const ChangeAmountEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

// تغيير الفئة
class ChangeCategoryEvent extends AddExpenseEvent {
  final String category;

  const ChangeCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

// تغيير الفئة المخصصة
class ChangeCustomCategoryEvent extends AddExpenseEvent {
  final String customCategory;

  const ChangeCustomCategoryEvent(this.customCategory);

  @override
  List<Object?> get props => [customCategory];
}

// تغيير التاريخ
class ChangeDateEvent extends AddExpenseEvent {
  final DateTime date;

  const ChangeDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

// تغيير الحساب
class ChangeAccountEvent extends AddExpenseEvent {
  final String? accountId;

  const ChangeAccountEvent(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

// تغيير الملاحظات
class ChangeNotesEvent extends AddExpenseEvent {
  final String notes;

  const ChangeNotesEvent(this.notes);

  @override
  List<Object?> get props => [notes];
}

// تحميل بيانات الأعمال (projects, vendors)
class LoadBusinessDataEvent extends AddExpenseEvent {
  const LoadBusinessDataEvent();
}

// تغيير المشروع
class ChangeProjectEvent extends AddExpenseEvent {
  final String? projectId;

  const ChangeProjectEvent(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

// تغيير الموظف
class ChangeEmployeeEvent extends AddExpenseEvent {
  final String? employeeId;

  const ChangeEmployeeEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

// تغيير القسم
class ChangeDepartmentEvent extends AddExpenseEvent {
  final String department;

  const ChangeDepartmentEvent(this.department);

  @override
  List<Object?> get props => [department];
}

// تغيير رقم الفاتورة
class ChangeInvoiceNumberEvent extends AddExpenseEvent {
  final String invoiceNumber;

  const ChangeInvoiceNumberEvent(this.invoiceNumber);

  @override
  List<Object?> get props => [invoiceNumber];
}

// تغيير المورد
class ChangeVendorEvent extends AddExpenseEvent {
  final String vendorName;

  const ChangeVendorEvent(this.vendorName);

  @override
  List<Object?> get props => [vendorName];
}

// حفظ المصروف
class SaveExpenseEvent extends AddExpenseEvent {
  final String? expenseIdToEdit; // null إذا كان مصروف جديد

  const SaveExpenseEvent({this.expenseIdToEdit});

  @override
  List<Object?> get props => [expenseIdToEdit];
}
