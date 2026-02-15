// ✅ Project Dialog - Uses ProjectCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/utils/responsive_utils.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/projects/domain/entities/project_status.dart';
import 'package:expense_tracker/features/projects/presentation/cubit/project_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_state.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_name_field.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_budget_field.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_status_selector.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_date_fields.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_priority_slider.dart';
import 'package:expense_tracker/features/projects/presentation/widgets/project_dialog/project_optional_fields.dart';

class ProjectDialog extends StatefulWidget {
  final ProjectEntity? project;

  const ProjectDialog({super.key, this.project});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _managerNameController = TextEditingController();

  ProjectStatus _selectedStatus = ProjectStatus.planning;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int _priority = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _initializeWithProject(widget.project!);
    }
  }

  void _initializeWithProject(ProjectEntity project) {
    _nameController.text = project.name;
    _descriptionController.text = project.description ?? '';
    _budgetController.text = project.budget.toString();
    _clientNameController.text = project.clientName ?? '';
    _managerNameController.text = project.managerName ?? '';
    _selectedStatus = project.status;
    _startDate = project.startDate;
    _endDate = project.endDate;
    _priority = project.priority;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _clientNameController.dispose();
    _managerNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final project =
          widget.project?.copyWith(
            name: _nameController.text.trim(),
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            budget: double.parse(_budgetController.text),
            status: _selectedStatus,
            startDate: _startDate,
            endDate: _endDate,
            priority: _priority,
            clientName:
                _clientNameController.text.trim().isEmpty
                    ? null
                    : _clientNameController.text.trim(),
            managerName:
                _managerNameController.text.trim().isEmpty
                    ? null
                    : _managerNameController.text.trim(),
            updatedAt: now,
          ) ??
          ProjectEntity(
            id: const Uuid().v4(),
            name: _nameController.text.trim(),
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            budget: double.parse(_budgetController.text),
            status: _selectedStatus,
            startDate: _startDate,
            endDate: _endDate,
            spentAmount: 0.0,
            priority: _priority,
            clientName:
                _clientNameController.text.trim().isEmpty
                    ? null
                    : _clientNameController.text.trim(),
            managerName:
                _managerNameController.text.trim().isEmpty
                    ? null
                    : _managerNameController.text.trim(),
            createdAt: now,
            updatedAt: now,
          );

      if (widget.project != null) {
        await context.read<ProjectCubit>().updateProject(widget.project!.id, project);
      } else {
        await context.read<ProjectCubit>().createProject(project);
      }

      if (mounted && context.canPop()) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final isRTL = context.read<SettingsCubit>().state.language == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRTL ? 'خطأ: $e' : 'Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final maxWidth = ResponsiveUtils.getDialogWidth(context);
    final isEditing = widget.project != null;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isRTL = settings.language == 'ar';

        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => !_isLoading,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.borderRadius),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? maxWidth : 500,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: settings.primaryColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(context.borderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color:
                              settings.isDarkMode ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEditing
                                ? (isRTL ? 'تعديل المشروع' : 'Edit Project')
                                : (isRTL ? 'مشروع جديد' : 'New Project'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  settings.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (context.canPop()) {
                                      context.pop();
                                    }
                                  },
                          icon: Icon(
                            Icons.close,
                            color:
                                settings.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project Name
                            ProjectNameField(
                              controller: _nameController,
                              isRTL: isRTL,
                            ),

                            const SizedBox(height: 16),

                            // Budget
                            ProjectBudgetField(
                              controller: _budgetController,
                              isRTL: isRTL,
                              currencySymbol: settings.currencySymbol,
                            ),

                            const SizedBox(height: 16),

                            // Status Selector
                            ProjectStatusSelector(
                              selectedStatus: _selectedStatus,
                              isRTL: isRTL,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedStatus = value);
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Date Fields
                            ProjectDateFields(
                              startDate: _startDate,
                              endDate: _endDate,
                              isRTL: isRTL,
                              onStartDateTap:
                                  () => _selectDate(isStartDate: true),
                              onEndDateTap:
                                  () => _selectDate(isStartDate: false),
                            ),

                            const SizedBox(height: 16),

                            // Priority Slider
                            ProjectPrioritySlider(
                              priority: _priority,
                              isRTL: isRTL,
                              onChanged: (value) {
                                setState(() => _priority = value.round());
                              },
                            ),

                            const SizedBox(height: 16),

                            // Optional Fields
                            ProjectOptionalFields(
                              descriptionController: _descriptionController,
                              clientNameController: _clientNameController,
                              managerNameController: _managerNameController,
                              isRTL: isRTL,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: settings.primaryColor,
                          foregroundColor:
                              settings.isDarkMode ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color:
                                        settings.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isEditing ? Icons.check : Icons.add,
                                      color:
                                          settings.isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing
                                          ? (isRTL ? 'تحديث' : 'Update')
                                          : (isRTL ? 'إضافة' : 'Add'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            settings.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
