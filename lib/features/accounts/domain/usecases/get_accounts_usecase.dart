import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class GetAccountsUseCase {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  Future<List<AccountEntity>> call({bool activeOnly = false}) {
    if (activeOnly) {
      return repository.getActiveAccounts();
    }
    return repository.loadAccounts();
  }
}
