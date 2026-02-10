import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/companies/data/models/company.dart';
import 'package:expense_tracker/features/companies/data/datasources/company_api_service.dart';
import 'package:expense_tracker/features/companies/presentation/cubit/company_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyApiService _companyApiService;

  CompanyCubit({CompanyApiService? companyApiService})
    : _companyApiService = companyApiService ?? serviceLocator.companyService,
      super(const CompanyState());

  /// Load the current user's company
  Future<void> loadCompany({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🔄 Loading company...');
      final company = await _companyApiService.getMyCompany(
        forceRefresh: forceRefresh,
      );

      debugPrint('✅ Company loaded: ${company?.name ?? 'No company found'}');

      emit(
        state.copyWith(
          company: company,
          isLoading: false,
          clearCompany: company == null,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error loading company: $error');
      String errorMessage = 'Failed to load company';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (error.toString().contains('UnauthorizedException') ||
          error.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please log in again.';
      } else {
        errorMessage =
            'Failed to load company: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Create a new company
  Future<void> createCompany(Company company) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('➕ Creating company: ${company.name}');
      final createdCompany = await _companyApiService.createCompany(company);

      debugPrint('✅ Company created: ${createdCompany.id}');

      emit(state.copyWith(company: createdCompany, isLoading: false));
    } catch (error) {
      debugPrint('❌ Error creating company: $error');
      String errorMessage = 'Failed to create company';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to create company: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Update the current company
  Future<void> updateCompany(Company company) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('✏️ Updating company: ${company.id}');
      final updatedCompany = await _companyApiService.updateCompany(company);

      debugPrint('✅ Company updated: ${updatedCompany.id}');

      emit(state.copyWith(company: updatedCompany, isLoading: false));
    } catch (error) {
      debugPrint('❌ Error updating company: $error');
      String errorMessage = 'Failed to update company';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to update company: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Delete the current company
  Future<void> deleteCompany() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🗑️ Deleting company...');
      await _companyApiService.deleteCompany();

      debugPrint('✅ Company deleted');

      emit(state.copyWith(isLoading: false, clearCompany: true));
    } catch (error) {
      debugPrint('❌ Error deleting company: $error');
      String errorMessage = 'Failed to delete company';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to delete company: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }
}
