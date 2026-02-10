// Home Feature - Domain Layer - Use Case
import 'package:expense_tracker/features/expenses/data/models/expense.dart';

class CalculateTotalAmountUseCase {
  double call(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
