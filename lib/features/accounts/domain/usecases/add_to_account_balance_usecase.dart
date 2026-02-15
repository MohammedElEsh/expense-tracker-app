import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class AddToAccountBalanceUseCase {
  final AccountRepository repository;

  AddToAccountBalanceUseCase(this.repository);

  Future<void> call(String accountId, double amount) =>
      repository.addToAccountBalance(accountId, amount);
}
