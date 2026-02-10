// Add Expense - Business Fields Widget
import 'package:flutter/material.dart';
import 'package:expense_tracker/features/projects/data/models/project.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';

class BusinessFields extends StatelessWidget {
  final bool isRTL;
  final String? selectedProjectId;
  final List<Project> availableProjects;
  final TextEditingController departmentController;
  final TextEditingController invoiceNumberController;
  final TextEditingController vendorNameController;
  final List<String> availableVendors;
  final String? selectedEmployeeId;
  final List<User> availableEmployees;
  final Function(String?) onProjectChanged;
  final Function(String?) onEmployeeChanged;
  final Function(String)? onDepartmentChanged;
  final Function(String)? onInvoiceNumberChanged;
  final Function(String)? onVendorChanged;

  const BusinessFields({
    super.key,
    required this.isRTL,
    required this.selectedProjectId,
    required this.availableProjects,
    required this.departmentController,
    required this.invoiceNumberController,
    required this.vendorNameController,
    required this.availableVendors,
    required this.selectedEmployeeId,
    required this.availableEmployees,
    required this.onProjectChanged,
    required this.onEmployeeChanged,
    this.onDepartmentChanged,
    this.onInvoiceNumberChanged,
    this.onVendorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          isRTL ? 'معلومات تجارية' : 'Business Information',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Project Selection
        DropdownButtonFormField<String>(
          initialValue:
              selectedProjectId != null &&
                      availableProjects.any((p) => p.id == selectedProjectId)
                  ? selectedProjectId
                  : null,
          decoration: InputDecoration(
            labelText: isRTL ? 'المشروع' : 'Project',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.work),
            hintText: isRTL ? 'اختر مشروع' : 'Select Project',
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                isRTL ? 'بدون مشروع' : 'No Project',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ...availableProjects.map((project) {
              return DropdownMenuItem<String>(
                value: project.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: project.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onProjectChanged,
        ),
        const SizedBox(height: 12),

        // Department
        TextFormField(
          controller: departmentController,
          decoration: InputDecoration(
            labelText: isRTL ? 'القسم' : 'Department',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.business),
            hintText: isRTL ? 'اختياري' : 'Optional',
          ),
          onChanged: onDepartmentChanged,
        ),
        const SizedBox(height: 12),

        // Invoice Number
        TextFormField(
          controller: invoiceNumberController,
          decoration: InputDecoration(
            labelText: isRTL ? 'رقم الفاتورة' : 'Invoice Number',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.receipt_long),
            hintText: isRTL ? 'اختياري' : 'Optional',
          ),
          onChanged: onInvoiceNumberChanged,
        ),
        const SizedBox(height: 12),

        // Vendor Name (Autocomplete)
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return availableVendors.where((vendor) {
              return vendor.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              );
            });
          },
          onSelected: (vendor) {
            vendorNameController.text = vendor;
            if (onVendorChanged != null) {
              onVendorChanged!(vendor);
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync with parent controller
            if (vendorNameController.text != controller.text) {
              controller.text = vendorNameController.text;
            }
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: isRTL ? 'اسم المورد' : 'Vendor Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.store),
                hintText: isRTL ? 'اختياري' : 'Optional',
              ),
              onChanged: (value) {
                vendorNameController.text = value;
                if (onVendorChanged != null) {
                  onVendorChanged!(value);
                }
              },
            );
          },
        ),
        const SizedBox(height: 12),

        // Employee Selection
        if (availableEmployees.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: selectedEmployeeId,
            decoration: InputDecoration(
              labelText: isRTL ? 'الموظف المسؤول' : 'Responsible Employee',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person),
              hintText: isRTL ? 'اختر موظف' : 'Select Employee',
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  isRTL ? 'بدون موظف' : 'No Employee',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ...availableEmployees.map((employee) {
                return DropdownMenuItem<String>(
                  value: employee.id,
                  child: Text(employee.name),
                );
              }),
            ],
            onChanged: onEmployeeChanged,
          ),
      ],
    );
  }
}
