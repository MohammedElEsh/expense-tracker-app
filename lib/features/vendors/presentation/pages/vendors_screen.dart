// Clean Architecture - Vendors Screen (Cubit only)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_entity.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_status.dart';
import 'package:expense_tracker/features/vendors/presentation/utils/vendor_display_helper.dart';
import 'package:expense_tracker/features/vendors/domain/entities/vendor_type.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_cubit.dart';
import 'package:expense_tracker/features/vendors/presentation/cubit/vendor_state.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/vendor_card.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/vendor_dialog.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/list/vendors_search_filter.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    context.read<VendorCubit>().loadVendors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showVendorDialog({VendorEntity? vendor}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => VendorDialog(vendor: vendor),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vendor == null
                ? (context.read<SettingsCubit>().state.language == 'ar' ? 'تم إضافة المورد بنجاح' : 'Vendor added successfully')
                : (context.read<SettingsCubit>().state.language == 'ar' ? 'تم تحديث المورد بنجاح' : 'Vendor updated successfully'),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteVendor(VendorEntity vendor) async {
    final isRTL = context.read<SettingsCubit>().state.language == 'ar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRTL ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          '${isRTL ? "هل أنت متأكد من حذف المورد" : "Are you sure you want to delete vendor"} "${vendor.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(isRTL ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(isRTL ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<VendorCubit>().deleteVendor(vendor.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isRTL ? 'تم حذف المورد بنجاح' : 'Vendor deleted successfully')),
        );
      }
    }
  }

  void _navigateToVendorDetails(VendorEntity vendor) {
    context.push(AppRoutes.vendorDetails, extra: vendor).then((_) {
      if (mounted) context.read<VendorCubit>().loadVendors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return BlocConsumer<VendorCubit, VendorState>(
          listener: (context, state) {
            if (state is VendorError && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          builder: (context, state) {
            return Directionality(
              textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    isRTL ? 'إدارة الموردين' : 'Vendor Management',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: state is VendorLoading ? null : () => context.read<VendorCubit>().loadVendors(),
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    isScrollable: true,
                    tabs: [
                      Tab(icon: const Icon(Icons.list), text: isRTL ? 'الكل' : 'All'),
                      Tab(icon: const Icon(Icons.inventory), text: isRTL ? 'موردين' : 'Suppliers'),
                      Tab(icon: const Icon(Icons.build), text: isRTL ? 'خدمات' : 'Services'),
                      Tab(icon: const Icon(Icons.construction), text: isRTL ? 'مقاولين' : 'Contractors'),
                      Tab(icon: const Icon(Icons.psychology), text: isRTL ? 'استشاريين' : 'Consultants'),
                      Tab(icon: const Icon(Icons.check_circle), text: isRTL ? 'نشط' : 'Active'),
                      Tab(icon: const Icon(Icons.analytics), text: isRTL ? 'إحصائيات' : 'Statistics'),
                    ],
                  ),
                ),
                body: state is VendorLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is VendorError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  state.message,
                                  style: AppTypography.titleMedium.copyWith(color: AppColors.error),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                ElevatedButton.icon(
                                  onPressed: () => context.read<VendorCubit>().loadVendors(),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(isRTL ? 'إعادة المحاولة' : 'Retry'),
                                ),
                              ],
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAllVendorsTab(state, isRTL),
                              _buildVendorsByType(state, VendorType.supplier, isRTL),
                              _buildVendorsByType(state, VendorType.serviceProvider, isRTL),
                              _buildVendorsByType(state, VendorType.contractor, isRTL),
                              _buildVendorsByType(state, VendorType.consultant, isRTL),
                              _buildVendorsByStatus(state, VendorStatus.active, isRTL),
                              _buildStatisticsTab(state, isRTL),
                            ],
                          ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _showVendorDialog(),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllVendorsTab(VendorState state, bool isRTL) {
    if (state is! VendorLoaded) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        VendorsSearchFilter(
          searchController: _searchController,
          searchQuery: state.searchQuery ?? '',
          selectedType: state.selectedType,
          selectedStatus: state.selectedStatus,
          onSearchChanged: (q) => context.read<VendorCubit>().searchVendors(q),
          onTypeChanged: (t) => context.read<VendorCubit>().filterByType(t),
          onStatusChanged: (s) => context.read<VendorCubit>().filterByStatus(s),
          isRTL: isRTL,
        ),
        Expanded(child: _buildVendorsList(state.filteredVendors, isRTL)),
      ],
    );
  }

  Widget _buildVendorsByType(VendorState state, VendorType type, bool isRTL) {
    if (state is! VendorLoaded) return const Center(child: CircularProgressIndicator());
    final vendors = state.vendors.where((v) => v.type == type).toList();
    return _buildVendorsList(vendors, isRTL);
  }

  Widget _buildVendorsByStatus(VendorState state, VendorStatus status, bool isRTL) {
    if (state is! VendorLoaded) return const Center(child: CircularProgressIndicator());
    final vendors = state.vendors.where((v) => v.status == status).toList();
    return _buildVendorsList(vendors, isRTL);
  }

  Widget _buildVendorsList(List<VendorEntity> vendors, bool isRTL) {
    if (vendors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.textDisabledLight),
            const SizedBox(height: AppSpacing.md),
            Text(
              isRTL ? 'لا يوجد موردين' : 'No vendors',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return VendorCard(
          vendor: vendor,
          isRTL: isRTL,
          onTap: () => _navigateToVendorDetails(vendor),
          onDelete: () => _deleteVendor(vendor),
        );
      },
    );
  }

  Widget _buildStatisticsTab(VendorState state, bool isRTL) {
    if (state is! VendorLoaded || state.statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = state.statistics!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Text(
            isRTL ? 'إحصائيات الموردين' : 'Vendor Statistics',
            style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${stats['totalVendors'] ?? 0} ${isRTL ? "مورد" : "vendors"}',
            style: AppTypography.headlineSmall,
          ),
        ],
      ),
    );
  }
}
