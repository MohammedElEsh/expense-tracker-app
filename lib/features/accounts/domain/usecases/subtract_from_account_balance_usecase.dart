import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class SubtractFromAccountBalanceUseCase {
  final AccountRepository repository;

  SubtractFromAccountBalanceUseCase(this.repository);

  Future<void> call(String accountId, double amount) =>
      repository.subtractFromAccountBalance(accountId, amount);
}
