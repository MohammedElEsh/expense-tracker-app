import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';

class CompanyState extends Equatable {
  final Company? company;
  final bool isLoading;
  final String? error;

  const CompanyState({this.company, this.isLoading = false, this.error});

  @override
  List<Object?> get props => [company, isLoading, error];

  CompanyState copyWith({
    Company? company,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCompany = false,
  }) {
    return CompanyState(
      company: clearCompany ? null : (company ?? this.company),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
