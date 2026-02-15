// ✅ Edit User Screen - Uses UserCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/users/presentation/utils/user_role_display.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

/// Edit User Screen - Allows Owner to edit user name and role
class EditUserScreen extends StatefulWidget {
  final UserEntity userEntity;

  const EditUserScreen({super.key, required this.userEntity});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userEntity.name);
    _selectedRole = widget.userEntity.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final userId = widget.userEntity.id;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'خطأ: معرف المستخدم غير موجود' : 'Error: User ID not found',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserRole? roleToUpdate = _selectedRole == UserRole.owner ? null : _selectedRole;

      await context.read<UserCubit>().updateUserFromApi(
        userId: userId,
        name: _nameController.text.trim(),
        role: roleToUpdate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'تم تحديث المستخدم بنجاح' : 'User updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      if (mounted) {
        String errorMessage;
        if (e is ValidationException) {
          errorMessage = e.message;
        } else if (e is NetworkException) {
          errorMessage =
              isRTL
                  ? 'خطأ في الاتصال بالشبكة'
                  : 'Network error. Please check your connection.';
        } else if (e is ServerException) {
          errorMessage = e.message;
        } else {
          errorMessage =
              isRTL
                  ? 'فشل تحديث المستخدم'
                  : 'Failed to update user: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final userEmail = widget.userEntity.email;
    final isOwner = widget.userEntity.role == UserRole.owner;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'تعديل المستخدم' : 'Edit User'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'معلومات المستخدم' : 'User Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              userEmail,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'الاسم' : 'Name',
                  hintText: isRTL ? 'أدخل اسم المستخدم' : 'Enter user name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isRTL ? 'الاسم مطلوب' : 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return isRTL
                        ? 'الاسم يجب أن يكون على الأقل حرفين'
                        : 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Role Selector
              Text(
                isRTL ? 'الدور' : 'Role',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Show current role if owner
              if (isOwner)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isRTL
                                ? 'لا يمكن تغيير دور المدير العام'
                                : 'Owner role cannot be changed',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ...UserRole.values
                  .where((role) => role != UserRole.owner)
                  .map(
                    (role) => RadioListTile<UserRole>(
                      title: Text(role.getDisplayName(isRTL)),
                      subtitle: Text(
                        role.getDescription(isRTL),
                        style: theme.textTheme.bodySmall,
                      ),
                      value: role,
                      groupValue: _selectedRole == UserRole.owner ? UserRole.employee : _selectedRole,
                      onChanged: isOwner
                          ? null
                          : (value) {
                              if (value != null) setState(() => _selectedRole = value);
                            },
                      secondary: Icon(role.icon, color: role.color),
                    ),
                  ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(isRTL ? 'حفظ التغييرات' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
