import 'package:expense_tracker/features/accounts/domain/repositories/account_repository.dart';

class InitializeAccountsUseCase {
  final AccountRepository repository;

  InitializeAccountsUseCase(this.repository);

  Future<void> call() => repository.initializeDefaultAccounts();
}
