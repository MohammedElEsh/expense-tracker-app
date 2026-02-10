import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/features/vendors/data/datasources/vendor_service.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

class VendorCubit extends Cubit<VendorState> {
  final VendorService _vendorService;

  VendorCubit({VendorService? vendorService})
    : _vendorService = vendorService ?? serviceLocator.vendorService,
      super(const VendorState());

  /// Load all vendors from API
  Future<void> loadVendors() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🔄 Loading vendors...');
      final vendors = await _vendorService.getAllVendors();

      debugPrint('✅ Loaded ${vendors.length} vendors');

      final filteredVendors = _applyFilters(vendors);

      emit(
        state.copyWith(
          vendors: vendors,
          filteredVendors: filteredVendors,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error loading vendors: $error');
      String errorMessage = 'Failed to load vendors';

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
            'Failed to load vendors: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Create a new vendor
  Future<void> createVendor(Vendor vendor) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('➕ Creating vendor: ${vendor.name}');
      final createdVendor = await _vendorService.createVendor(vendor);

      debugPrint('✅ Vendor created: ${createdVendor.id}');

      final updatedVendors = List<Vendor>.from(state.vendors)
        ..add(createdVendor);
      final filteredVendors = _applyFilters(updatedVendors);

      emit(
        state.copyWith(
          vendors: updatedVendors,
          filteredVendors: filteredVendors,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error creating vendor: $error');
      String errorMessage = 'Failed to create vendor';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to create vendor: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Update an existing vendor
  Future<void> updateVendor(Vendor vendor) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('✏️ Updating vendor: ${vendor.id}');
      final updatedVendor = await _vendorService.updateVendor(vendor);

      debugPrint('✅ Vendor updated: ${updatedVendor.id}');

      final updatedVendors = List<Vendor>.from(state.vendors);
      final index = updatedVendors.indexWhere((v) => v.id == vendor.id);
      if (index != -1) {
        updatedVendors[index] = updatedVendor;
      }
      final filteredVendors = _applyFilters(updatedVendors);

      emit(
        state.copyWith(
          vendors: updatedVendors,
          filteredVendors: filteredVendors,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error updating vendor: $error');
      String errorMessage = 'Failed to update vendor';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ValidationException')) {
        errorMessage = error.toString().replaceAll('Exception: ', '');
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to update vendor: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Delete a vendor by ID
  Future<void> deleteVendor(String vendorId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      debugPrint('🗑️ Deleting vendor: $vendorId');
      await _vendorService.deleteVendor(vendorId);

      debugPrint('✅ Vendor deleted: $vendorId');

      final updatedVendors = List<Vendor>.from(state.vendors)
        ..removeWhere((v) => v.id == vendorId);
      final filteredVendors = _applyFilters(updatedVendors);

      emit(
        state.copyWith(
          vendors: updatedVendors,
          filteredVendors: filteredVendors,
          isLoading: false,
        ),
      );
    } catch (error) {
      debugPrint('❌ Error deleting vendor: $error');
      String errorMessage = 'Failed to delete vendor';

      if (error.toString().contains('NetworkException') ||
          error.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (error.toString().contains('ServerException')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage =
            'Failed to delete vendor: ${error.toString().replaceAll('Exception: ', '')}';
      }

      emit(state.copyWith(isLoading: false, error: errorMessage));
    }
  }

  /// Search vendors by query string
  void searchVendors(String query) {
    emit(
      state.copyWith(
        searchQuery: query.isEmpty ? null : query,
        clearSearchQuery: query.isEmpty,
        filteredVendors: _applyFilters(
          state.vendors,
          searchOverride: query.isEmpty ? null : query,
        ),
      ),
    );
  }

  /// Filter vendors by type
  void filterByType(VendorType? type) {
    emit(
      state.copyWith(
        selectedType: type,
        clearSelectedType: type == null,
        filteredVendors: _applyFilters(
          state.vendors,
          typeOverride: type,
          clearType: type == null,
        ),
      ),
    );
  }

  /// Filter vendors by status
  void filterByStatus(VendorStatus? status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        clearSelectedStatus: status == null,
        filteredVendors: _applyFilters(
          state.vendors,
          statusOverride: status,
          clearStatus: status == null,
        ),
      ),
    );
  }

  /// Clear all active filters
  void clearFilters() {
    emit(
      state.copyWith(
        clearSearchQuery: true,
        clearSelectedType: true,
        clearSelectedStatus: true,
        filteredVendors: state.vendors,
      ),
    );
  }

  /// Apply all active filters to the vendors list
  List<Vendor> _applyFilters(
    List<Vendor> vendors, {
    String? searchOverride,
    VendorType? typeOverride,
    VendorStatus? statusOverride,
    bool clearType = false,
    bool clearStatus = false,
  }) {
    var filtered = List<Vendor>.from(vendors);

    // Search filter
    final query = searchOverride ?? state.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered =
          filtered.where((vendor) {
            return vendor.name.toLowerCase().contains(lowerQuery) ||
                (vendor.companyName?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (vendor.email?.toLowerCase().contains(lowerQuery) ?? false) ||
                (vendor.phone?.contains(query) ?? false) ||
                (vendor.notes?.toLowerCase().contains(lowerQuery) ?? false);
          }).toList();
    }

    // Type filter
    final type = clearType ? null : (typeOverride ?? state.selectedType);
    if (type != null) {
      filtered = filtered.where((vendor) => vendor.type == type).toList();
    }

    // Status filter
    final status =
        clearStatus ? null : (statusOverride ?? state.selectedStatus);
    if (status != null) {
      filtered = filtered.where((vendor) => vendor.status == status).toList();
    }

    return filtered;
  }
}
