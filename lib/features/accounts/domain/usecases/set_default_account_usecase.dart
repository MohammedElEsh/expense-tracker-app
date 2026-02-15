import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class SetDefaultAccountUseCase {
  final AccountRepository repository;

  SetDefaultAccountUseCase(this.repository);

  Future<void> call(String accountId) => repository.setDefaultAccount(accountId);
}
