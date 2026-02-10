import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';

class VendorState extends Equatable {
  final List<Vendor> vendors;
  final List<Vendor> filteredVendors;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final VendorType? selectedType;
  final VendorStatus? selectedStatus;

  const VendorState({
    this.vendors = const [],
    this.filteredVendors = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedType,
    this.selectedStatus,
  });

  @override
  List<Object?> get props => [
    vendors,
    filteredVendors,
    isLoading,
    error,
    searchQuery,
    selectedType,
    selectedStatus,
  ];

  VendorState copyWith({
    List<Vendor>? vendors,
    List<Vendor>? filteredVendors,
    bool? isLoading,
    String? error,
    String? searchQuery,
    VendorType? selectedType,
    VendorStatus? selectedStatus,
    bool clearError = false,
    bool clearSearchQuery = false,
    bool clearSelectedType = false,
    bool clearSelectedStatus = false,
  }) {
    return VendorState(
      vendors: vendors ?? this.vendors,
      filteredVendors: filteredVendors ?? this.filteredVendors,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      selectedType:
          clearSelectedType ? null : (selectedType ?? this.selectedType),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }

  /// Whether any filters are currently active
  bool get hasActiveFilters =>
      searchQuery != null || selectedType != null || selectedStatus != null;
}
