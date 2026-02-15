import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class UpdateAccountBalanceUseCase {
  final AccountRepository repository;

  UpdateAccountBalanceUseCase(this.repository);

  Future<void> call(String accountId, double newBalance) =>
      repository.updateAccountBalance(accountId, newBalance);
}
