import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/accounts/data/models/account.dart';

// ✅ Clean Architecture - BLoC Events

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAccounts extends AccountEvent {
  const InitializeAccounts();
}

class LoadAccounts extends AccountEvent {
  const LoadAccounts();
}

class LoadDefaultAccount extends AccountEvent {
  const LoadDefaultAccount();
}

class AddAccount extends AccountEvent {
  final Account account;

  const AddAccount(this.account);

  @override
  List<Object> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final String accountId;

  const DeleteAccount(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class SetDefaultAccount extends AccountEvent {
  final String accountId;

  const SetDefaultAccount(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class UpdateAccountBalance extends AccountEvent {
  final String accountId;
  final double newBalance;

  const UpdateAccountBalance(this.accountId, this.newBalance);

  @override
  List<Object> get props => [accountId, newBalance];
}

class AddToAccountBalance extends AccountEvent {
  final String accountId;
  final double amount;

  const AddToAccountBalance(this.accountId, this.amount);

  @override
  List<Object> get props => [accountId, amount];
}

class SubtractFromAccountBalance extends AccountEvent {
  final String accountId;
  final double amount;

  const SubtractFromAccountBalance(this.accountId, this.amount);

  @override
  List<Object> get props => [accountId, amount];
}

class TransferMoney extends AccountEvent {
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final String description;

  const TransferMoney({
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.description,
  });

  @override
  List<Object> get props => [fromAccountId, toAccountId, amount, description];
}

class ToggleAccountActive extends AccountEvent {
  final String accountId;
  final bool isActive;

  const ToggleAccountActive(this.accountId, this.isActive);

  @override
  List<Object> get props => [accountId, isActive];
}

class ToggleIncludeInTotal extends AccountEvent {
  final String accountId;
  final bool includeInTotal;

  const ToggleIncludeInTotal(this.accountId, this.includeInTotal);

  @override
  List<Object> get props => [accountId, includeInTotal];
}
