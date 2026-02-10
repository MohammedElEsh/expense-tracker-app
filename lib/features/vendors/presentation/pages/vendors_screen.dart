// ✅ Clean Architecture - Vendors Screen (Refactored)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/vendors/data/models/vendor.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/vendor_card.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/vendor_dialog_refactored.dart';
import 'package:expense_tracker/widgets/animated_page_route.dart';
import 'package:expense_tracker/features/vendors/presentation/pages/vendor_details_screen.dart';
import 'package:expense_tracker/features/vendors/presentation/widgets/list/vendors_search_filter.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Vendor> _allVendors = [];
  List<Vendor> _filteredVendors = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String _searchQuery = '';
  VendorType? _selectedType;
  VendorStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadVendors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendors() async {
    setState(() => _isLoading = true);

    try {
      final vendorService = serviceLocator.vendorService;
      final vendors = await vendorService.getAllVendors();
      final statistics = await vendorService.getVendorsStatistics();

      setState(() {
        _allVendors = vendors;
        _filteredVendors = vendors;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل الموردين: $e')));
      }
    }
  }

  void _filterVendors() {
    setState(() {
      _filteredVendors =
          _allVendors.where((vendor) {
            final matchesSearch =
                _searchQuery.isEmpty ||
                vendor.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (vendor.companyName?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (vendor.email?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false) ||
                (vendor.phone?.contains(_searchQuery) ?? false);

            final matchesType =
                _selectedType == null || vendor.type == _selectedType;
            final matchesStatus =
                _selectedStatus == null || vendor.status == _selectedStatus;

            return matchesSearch && matchesType && matchesStatus;
          }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterVendors();
  }

  void _onTypeFilterChanged(VendorType? type) {
    setState(() => _selectedType = type);
    _filterVendors();
  }

  void _onStatusFilterChanged(VendorStatus? status) {
    setState(() => _selectedStatus = status);
    _filterVendors();
  }

  Future<void> _showVendorDialog({Vendor? vendor}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => VendorDialogRefactored(vendor: vendor),
    );

    if (result == true) {
      await _loadVendors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vendor == null
                  ? 'تم إضافة المورد بنجاح'
                  : 'تم تحديث المورد بنجاح',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteVendor(Vendor vendor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text(
              'هل أنت متأكد من حذف المورد "${vendor.displayName}"؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('حذف'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final vendorService = serviceLocator.vendorService;
        await vendorService.deleteVendor(vendor.id);
        await _loadVendors();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم حذف المورد بنجاح')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('خطأ في حذف المورد: $e')));
        }
      }
    }
  }

  void _navigateToVendorDetails(Vendor vendor) {
    Navigator.push(
      context,
      AnimatedPageRoute(child: VendorDetailsScreen(vendor: vendor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        return Directionality(
          textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isRTL ? 'إدارة الموردين' : 'Vendor Management',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadVendors,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: true,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.list),
                    text: isRTL ? 'الكل' : 'All',
                  ),
                  Tab(
                    icon: const Icon(Icons.inventory),
                    text: isRTL ? 'موردين' : 'Suppliers',
                  ),
                  Tab(
                    icon: const Icon(Icons.build),
                    text: isRTL ? 'خدمات' : 'Services',
                  ),
                  Tab(
                    icon: const Icon(Icons.construction),
                    text: isRTL ? 'مقاولين' : 'Contractors',
                  ),
                  Tab(
                    icon: const Icon(Icons.psychology),
                    text: isRTL ? 'استشاريين' : 'Consultants',
                  ),
                  Tab(
                    icon: const Icon(Icons.check_circle),
                    text: isRTL ? 'نشط' : 'Active',
                  ),
                  Tab(
                    icon: const Icon(Icons.analytics),
                    text: isRTL ? 'إحصائيات' : 'Statistics',
                  ),
                ],
              ),
            ),
            body:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllVendorsTab(isRTL),
                        _buildVendorsByType(VendorType.supplier, isRTL),
                        _buildVendorsByType(VendorType.serviceProvider, isRTL),
                        _buildVendorsByType(VendorType.contractor, isRTL),
                        _buildVendorsByType(VendorType.consultant, isRTL),
                        _buildVendorsByStatus(VendorStatus.active, isRTL),
                        _buildStatisticsTab(isRTL),
                      ],
                    ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showVendorDialog(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllVendorsTab(bool isRTL) {
    return Column(
      children: [
        VendorsSearchFilter(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedType: _selectedType,
          selectedStatus: _selectedStatus,
          onSearchChanged: _onSearchChanged,
          onTypeChanged: _onTypeFilterChanged,
          onStatusChanged: _onStatusFilterChanged,
          isRTL: isRTL,
        ),
        Expanded(child: _buildVendorsList(_filteredVendors, isRTL)),
      ],
    );
  }

  Widget _buildVendorsByType(VendorType type, bool isRTL) {
    final vendors = _allVendors.where((v) => v.type == type).toList();
    return _buildVendorsList(vendors, isRTL);
  }

  Widget _buildVendorsByStatus(VendorStatus status, bool isRTL) {
    final vendors = _allVendors.where((v) => v.status == status).toList();
    return _buildVendorsList(vendors, isRTL);
  }

  Widget _buildVendorsList(List<Vendor> vendors, bool isRTL) {
    if (vendors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isRTL ? 'لا يوجد موردين' : 'No vendors',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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

  Widget _buildStatisticsTab(bool isRTL) {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            isRTL ? 'إحصائيات الموردين' : 'Vendor Statistics',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            '${_statistics!['totalVendors'] ?? 0} ${isRTL ? "مورد" : "vendors"}',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
