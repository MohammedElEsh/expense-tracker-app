// Projects - Search and Filter Widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

class ProjectsSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ProjectStatus? selectedStatus;
  final Function(String) onSearchChanged;
  final Function(ProjectStatus?) onStatusChanged;
  final bool isRTL;

  const ProjectsSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
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
                  hintText:
                      isRTL ? 'البحث في المشاريع...' : 'Search projects...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      searchQuery.isNotEmpty
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
                      isSelected: selectedStatus == null,
                      onTap: () => onStatusChanged(null),
                      settings: settings,
                    ),
                    const SizedBox(width: 8),
                    ...ProjectStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          label: status.getDisplayName(isRTL),
                          isSelected: selectedStatus == status,
                          onTap: () => onStatusChanged(status),
                          settings: settings,
                        ),
                      ),
                    ),
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
          color:
              isSelected
                  ? Colors.blue
                  : settings.isDarkMode
                  ? Colors.grey[800]
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : settings.isDarkMode
                    ? Colors.white
                    : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
