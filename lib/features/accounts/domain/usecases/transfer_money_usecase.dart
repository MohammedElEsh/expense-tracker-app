import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class TransferMoneyUseCase {
  final AccountRepository repository;

  TransferMoneyUseCase(this.repository);

  Future<bool> call({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    String? notes,
  }) =>
      repository.transferMoney(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        notes: notes,
      );
}
