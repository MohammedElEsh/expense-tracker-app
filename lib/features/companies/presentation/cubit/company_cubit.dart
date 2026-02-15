import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/companies/domain/entities/company_entity.dart';
import 'package:expense_tracker/features/companies/domain/usecases/create_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/delete_company_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_company_by_id_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/get_companies_usecase.dart';
import 'package:expense_tracker/features/companies/domain/usecases/update_company_usecase.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_state.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final GetCompaniesUseCase getCompaniesUseCase;
  final GetCompanyByIdUseCase getCompanyByIdUseCase;
  final CreateCompanyUseCase createCompanyUseCase;
  final UpdateCompanyUseCase updateCompanyUseCase;
  final DeleteCompanyUseCase deleteCompanyUseCase;

  CompanyCubit({
    required this.getCompaniesUseCase,
    required this.getCompanyByIdUseCase,
    required this.createCompanyUseCase,
    required this.updateCompanyUseCase,
    required this.deleteCompanyUseCase,
  }) : super(const CompanyInitial());

  static String _messageFromError(Object error) {
    final s = error.toString();
    if (s.contains('NetworkException') || s.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    if (s.contains('ServerException')) return 'Server error. Please try again later.';
    if (s.contains('UnauthorizedException') || s.contains('401')) {
      return 'Authentication failed. Please log in again.';
    }
    if (s.contains('ValidationException')) {
      return s.replaceAll('Exception: ', '');
    }
    return s.replaceAll('Exception: ', '');
  }

  Future<void> loadCompany({bool forceRefresh = false}) async {
    if (state is CompanyLoading) return;
    emit(const CompanyLoading());
    try {
      final company = await getCompaniesUseCase(forceRefresh: forceRefresh);
      emit(CompanyLoaded(company: company));
    } catch (e) {
      debugPrint('CompanyCubit loadCompany error: $e');
      emit(CompanyError(_messageFromError(e)));
    }
  }

  /// Load a single company by id (e.g. when opening details by id).
  Future<void> loadCompanyById(String id) async {
    if (state is CompanyLoading) return;
    emit(const CompanyLoading());
    try {
      final company = await getCompanyByIdUseCase(id);
      emit(CompanyLoaded(company: company));
    } catch (e) {
      debugPrint('CompanyCubit loadCompanyById error: $e');
      emit(CompanyError(_messageFromError(e)));
    }
  }

  Future<void> createCompany(CompanyEntity company) async {
    if (state is CompanyLoading) return;
    emit(const CompanyLoading());
    try {
      final created = await createCompanyUseCase(company);
      emit(CompanyLoaded(company: created));
    } catch (e) {
      debugPrint('CompanyCubit createCompany error: $e');
      emit(CompanyError(_messageFromError(e)));
    }
  }

  Future<void> updateCompany(CompanyEntity company) async {
    if (state is CompanyLoading) return;
    emit(const CompanyLoading());
    try {
      final updated = await updateCompanyUseCase(company);
      emit(CompanyLoaded(company: updated));
    } catch (e) {
      debugPrint('CompanyCubit updateCompany error: $e');
      emit(CompanyError(_messageFromError(e)));
    }
  }

  Future<void> deleteCompany() async {
    if (state is CompanyLoading) return;
    emit(const CompanyLoading());
    try {
      await deleteCompanyUseCase();
      emit(const CompanyLoaded(company: null));
    } catch (e) {
      debugPrint('CompanyCubit deleteCompany error: $e');
      emit(CompanyError(_messageFromError(e)));
    }
  }
}
