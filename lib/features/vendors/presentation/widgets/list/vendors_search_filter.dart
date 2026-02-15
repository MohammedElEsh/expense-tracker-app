import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';
import 'package:expense_tracker/features/vendors/presentation/utils/vendor_display_helper.dart';

class VendorsSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final VendorType? selectedType;
  final VendorStatus? selectedStatus;
  final Function(String) onSearchChanged;
  final Function(VendorType?) onTypeChanged;
  final Function(VendorStatus?) onStatusChanged;
  final bool isRTL;

  const VendorsSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedType,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: settings.backgroundCardColor,
            border: Border(bottom: BorderSide(color: settings.borderColor)),
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: isRTL ? 'البحث في الموردين...' : 'Search vendors...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: settings.surfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: isRTL ? 'الكل' : 'All',
                      isSelected: selectedType == null && selectedStatus == null,
                      onTap: () {
                        onTypeChanged(null);
                        onStatusChanged(null);
                      },
                      settings: settings,
                    ),
                    const SizedBox(width: 8),
                    ...VendorType.values.map((type) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            label: type.displayName(isRTL),
                            isSelected: selectedType == type,
                            onTap: () => onTypeChanged(type),
                            settings: settings,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required SettingsState settings,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : (settings.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (settings.isDarkMode ? Colors.white : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
