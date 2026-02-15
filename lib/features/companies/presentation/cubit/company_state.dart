import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';

/// Base for company screen states.
sealed class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load.
final class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

/// Loading in progress.
final class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

/// Data loaded (company may be null when user has no company).
final class CompanyLoaded extends CompanyState {
  final CompanyEntity? company;

  const CompanyLoaded({this.company});

  @override
  List<Object?> get props => [company];
}

/// Operation failed.
final class CompanyError extends CompanyState {
  final String message;

  const CompanyError(this.message);

  @override
  List<Object?> get props => [message];
}
