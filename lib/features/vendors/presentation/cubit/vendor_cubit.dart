import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/create_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/delete_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/get_vendors_statistics_usecase.dart';
import 'package:expense_tracker/features/vendors/domain/usecases/update_vendor_usecase.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';

class VendorCubit extends Cubit<VendorState> {
  final GetVendorsUseCase getVendorsUseCase;
  final CreateVendorUseCase createVendorUseCase;
  final UpdateVendorUseCase updateVendorUseCase;
  final DeleteVendorUseCase deleteVendorUseCase;
  final GetVendorsStatisticsUseCase getVendorsStatisticsUseCase;

  VendorCubit({
    required this.getVendorsUseCase,
    required this.createVendorUseCase,
    required this.updateVendorUseCase,
    required this.deleteVendorUseCase,
    required this.getVendorsStatisticsUseCase,
  }) : super(const VendorInitial());

  static String _messageFromError(Object error) {
    final s = error.toString();
    if (s.contains('NetworkException') || s.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    if (s.contains('ServerException')) return 'Server error. Please try again later.';
    if (s.contains('UnauthorizedException') || s.contains('401')) {
      return 'Authentication failed. Please log in again.';
    }
    if (s.contains('ValidationException')) return s.replaceAll('Exception: ', '');
    return s.replaceAll('Exception: ', '');
  }

  Future<void> loadVendors() async {
    if (state is VendorLoading) return;
    emit(const VendorLoading());
    try {
      final vendors = await getVendorsUseCase();
      final stats = await getVendorsStatisticsUseCase();
      final filtered = _applyFilters(vendors);
      emit(VendorLoaded(
        vendors: vendors,
        filteredVendors: filtered,
        statistics: stats,
      ));
    } catch (e) {
      debugPrint('VendorCubit loadVendors error: $e');
      emit(VendorError(_messageFromError(e)));
    }
  }

  Future<void> createVendor(VendorEntity vendor) async {
    if (state is VendorLoading) return;
    final prev = state is VendorLoaded ? state as VendorLoaded : null;
    emit(const VendorLoading());
    try {
      final created = await createVendorUseCase(vendor);
      final list = prev?.vendors ?? <VendorEntity>[];
      final updated = List<VendorEntity>.from(list)..add(created);
      final filtered = _applyFilters(updated, existingState: prev);
      emit(VendorLoaded(
        vendors: updated,
        filteredVendors: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedType: prev?.selectedType,
        selectedStatus: prev?.selectedStatus,
      ));
    } catch (e) {
      debugPrint('VendorCubit createVendor error: $e');
      emit(VendorError(_messageFromError(e)));
    }
  }

  Future<void> updateVendor(VendorEntity vendor) async {
    if (state is VendorLoading) return;
    final prev = state is VendorLoaded ? state as VendorLoaded : null;
    emit(const VendorLoading());
    try {
      final updatedVendor = await updateVendorUseCase(vendor);
      final list = prev?.vendors ?? <VendorEntity>[];
      final updated = list.map((v) => v.id == vendor.id ? updatedVendor : v).toList();
      final filtered = _applyFilters(updated, existingState: prev);
      emit(VendorLoaded(
        vendors: updated,
        filteredVendors: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedType: prev?.selectedType,
        selectedStatus: prev?.selectedStatus,
      ));
    } catch (e) {
      debugPrint('VendorCubit updateVendor error: $e');
      emit(VendorError(_messageFromError(e)));
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    if (state is VendorLoading) return;
    final prev = state is VendorLoaded ? state as VendorLoaded : null;
    emit(const VendorLoading());
    try {
      await deleteVendorUseCase(vendorId);
      final list = prev?.vendors ?? <VendorEntity>[];
      final updated = list.where((v) => v.id != vendorId).toList();
      final filtered = _applyFilters(updated, existingState: prev);
      emit(VendorLoaded(
        vendors: updated,
        filteredVendors: filtered,
        statistics: prev?.statistics,
        searchQuery: prev?.searchQuery,
        selectedType: prev?.selectedType,
        selectedStatus: prev?.selectedStatus,
      ));
    } catch (e) {
      debugPrint('VendorCubit deleteVendor error: $e');
      emit(VendorError(_messageFromError(e)));
    }
  }

  void searchVendors(String query) {
    final s = state;
    if (s is! VendorLoaded) return;
    final filtered = _applyFilters(
      s.vendors,
      searchOverride: query.isEmpty ? null : query,
      existingState: s,
    );
    emit(VendorLoaded(
      vendors: s.vendors,
      filteredVendors: filtered,
      statistics: s.statistics,
      searchQuery: query.isEmpty ? null : query,
      selectedType: s.selectedType,
      selectedStatus: s.selectedStatus,
    ));
  }

  void filterByType(VendorType? type) {
    final s = state;
    if (s is! VendorLoaded) return;
    final filtered = _applyFilters(s.vendors, typeOverride: type, existingState: s);
    emit(VendorLoaded(
      vendors: s.vendors,
      filteredVendors: filtered,
      statistics: s.statistics,
      searchQuery: s.searchQuery,
      selectedType: type,
      selectedStatus: s.selectedStatus,
    ));
  }

  void filterByStatus(VendorStatus? status) {
    final s = state;
    if (s is! VendorLoaded) return;
    final filtered = _applyFilters(s.vendors, statusOverride: status, existingState: s);
    emit(VendorLoaded(
      vendors: s.vendors,
      filteredVendors: filtered,
      statistics: s.statistics,
      searchQuery: s.searchQuery,
      selectedType: s.selectedType,
      selectedStatus: status,
    ));
  }

  void clearFilters() {
    final s = state;
    if (s is! VendorLoaded) return;
    emit(VendorLoaded(
      vendors: s.vendors,
      filteredVendors: s.vendors,
      statistics: s.statistics,
    ));
  }

  List<VendorEntity> _applyFilters(
    List<VendorEntity> vendors, {
    String? searchOverride,
    VendorType? typeOverride,
    VendorStatus? statusOverride,
    VendorState? existingState,
  }) {
    var filtered = List<VendorEntity>.from(vendors);
    final loaded = existingState is VendorLoaded ? existingState : null;

    final query = searchOverride ?? loaded?.searchQuery;
    if (query != null && query.isNotEmpty) {
      final lower = query.toLowerCase();
      filtered = filtered.where((v) {
        return v.name.toLowerCase().contains(lower) ||
            (v.companyName?.toLowerCase().contains(lower) ?? false) ||
            (v.email?.toLowerCase().contains(lower) ?? false) ||
            (v.phone?.contains(query) ?? false) ||
            (v.notes?.toLowerCase().contains(lower) ?? false);
      }).toList();
    }

    final type = typeOverride ?? loaded?.selectedType;
    if (type != null) filtered = filtered.where((v) => v.type == type).toList();

    final status = statusOverride ?? loaded?.selectedStatus;
    if (status != null) filtered = filtered.where((v) => v.status == status).toList();

    return filtered;
  }
}
