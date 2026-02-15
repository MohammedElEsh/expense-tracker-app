import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class CreateAccountUseCase {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  Future<AccountEntity> call(AccountEntity account) {
    if (account.name.trim().isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }
    return repository.addAccount(account);
  }
}
