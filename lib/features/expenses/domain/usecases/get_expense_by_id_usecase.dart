import 'package:expense_tracker/features/expenses/data/models/expense.dart';
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart';

/// Retrieves a single expense by id.
///
/// Delegates to [ExpenseRepository.getExpenseById].
class GetExpenseByIdUseCase {
  final ExpenseRepository repository;

  GetExpenseByIdUseCase(this.repository);

  Future<Expense> call(String expenseId) => repository.getExpenseById(expenseId);
}
