import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';

class DatabaseService {
  static const String _expenseBoxName = 'expenses';
  static late Box<Expense> _expenseBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all adapters
    Hive.registerAdapter(ExpenseAdapter()); // typeId: 0
    Hive.registerAdapter(UserAdapter()); // typeId: 1
    // typeId: 2 is reserved for other models
    Hive.registerAdapter(ProjectAdapter()); // typeId: 3
    Hive.registerAdapter(VendorAdapter()); // typeId: 4

    _expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
  }

  static Box<Expense> get expenseBox => _expenseBox;

  // Expense operations
  static Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  static Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  static List<Expense> getAllExpenses() {
    return _expenseBox.values.toList();
  }

  static List<Expense> getExpensesByDate(DateTime date) {
    return _expenseBox.values.where((expense) {
      return expense.date.year == date.year &&
          expense.date.month == date.month &&
          expense.date.day == date.day;
    }).toList();
  }

  static List<Expense> getExpensesByMonth(int year, int month) {
    return _expenseBox.values.where((expense) {
      return expense.date.year == year && expense.date.month == month;
    }).toList();
  }

  static Map<String, double> getCategoryTotals(List<Expense> expenses) {
    Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  static Future<void> deleteAllExpenses() async {
    await _expenseBox.clear();
  }

  static double getTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
