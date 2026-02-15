import 'package:expense_tracker/features/accounts/domain/entities/account_entity.dart';
import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class GetDefaultAccountUseCase {
  final AccountRepository repository;

  GetDefaultAccountUseCase(this.repository);

  Future<AccountEntity?> call() => repository.getDefaultAccount();
}
