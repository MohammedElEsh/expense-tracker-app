import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';

sealed class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object?> get props => [];
}

final class VendorInitial extends VendorState {
  const VendorInitial();
}

final class VendorLoading extends VendorState {
  const VendorLoading();
}

final class VendorLoaded extends VendorState {
  final List<VendorEntity> vendors;
  final List<VendorEntity> filteredVendors;
  final Map<String, dynamic>? statistics;
  final String? searchQuery;
  final VendorType? selectedType;
  final VendorStatus? selectedStatus;

  const VendorLoaded({
    required this.vendors,
    required this.filteredVendors,
    this.statistics,
    this.searchQuery,
    this.selectedType,
    this.selectedStatus,
  });

  bool get hasActiveFilters =>
      searchQuery != null && searchQuery!.isNotEmpty ||
      selectedType != null ||
      selectedStatus != null;

  @override
  List<Object?> get props => [
        vendors,
        filteredVendors,
        statistics,
        searchQuery,
        selectedType,
        selectedStatus,
      ];
}

final class VendorError extends VendorState {
  final String message;

  const VendorError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Convenience extension for UI (avoids casting in every builder).
extension VendorStateX on VendorState {
  bool get isLoading => this is VendorLoading;
  List<VendorEntity> get vendors =>
      this is VendorLoaded ? (this as VendorLoaded).vendors : [];
  List<VendorEntity> get filteredVendors =>
      this is VendorLoaded ? (this as VendorLoaded).filteredVendors : [];
}
