import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class UpdateAccountUseCase {
  final AccountRepository repository;

  UpdateAccountUseCase(this.repository);

  Future<AccountEntity> call(AccountEntity account) {
    if (account.id.trim().isEmpty) {
      throw ArgumentError('Account ID cannot be empty');
    }
    if (account.name.trim().isEmpty) {
      throw ArgumentError('Account name cannot be empty');
    }
    return repository.updateAccount(account);
  }
}
