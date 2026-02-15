// ✅ Add User Screen - Uses UserCubit only (no service/API access).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/features/users/presentation/utils/user_role_display.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

/// Add User Screen - Allows Owner to add new users (employee, accountant, auditor)
class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.employee;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    setState(() => _isLoading = true);

    try {
      await context.read<UserCubit>().addUser(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRole,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'تم إضافة المستخدم بنجاح' : 'User added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is ValidationException) {
          errorMessage = e.message;
        } else if (e is NetworkException) {
          errorMessage = isRTL
              ? 'خطأ في الاتصال بالشبكة'
              : 'Network error. Please check your connection.';
        } else if (e is ServerException) {
          errorMessage = e.message;
        } else {
          errorMessage =
              isRTL ? 'فشل إضافة المستخدم' : 'Failed to add user: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'إضافة مستخدم جديد' : 'Add New User'),
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
              const SizedBox(height: 16),
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

              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
                  hintText: isRTL ? 'user@example.com' : 'user@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isRTL
                        ? 'البريد الإلكتروني مطلوب'
                        : 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value.trim())) {
                    return isRTL
                        ? 'البريد الإلكتروني غير صحيح'
                        : 'Invalid email format';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'كلمة المرور' : 'Password',
                  hintText: isRTL ? 'أدخل كلمة المرور' : 'Enter password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: _obscurePassword,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isRTL
                        ? 'كلمة المرور مطلوبة'
                        : 'Password is required';
                  }
                  if (value.length < 8) {
                    return isRTL
                        ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                        : 'Password must be at least 8 characters';
                  }
                  if (!RegExp(
                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                  ).hasMatch(value)) {
                    return isRTL
                        ? 'كلمة المرور يجب أن تحتوي على حرف كبير وصغير ورقم'
                        : 'Password must contain uppercase, lowercase, and number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: isRTL ? 'تأكيد كلمة المرور' : 'Confirm Password',
                  hintText:
                      isRTL ? 'أعد إدخال كلمة المرور' : 'Re-enter password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return isRTL
                        ? 'تأكيد كلمة المرور مطلوب'
                        : 'Please confirm password';
                  }
                  if (value != _passwordController.text) {
                    return isRTL
                        ? 'كلمة المرور غير متطابقة'
                        : 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 96),

              // Role Selector
              Text(
                isRTL ? 'الدور' : 'Role',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              ...UserRole.values
                  .where((r) => r != UserRole.owner)
                  .map(
                    (role) => RadioListTile<UserRole>(
                      title: Text(role.getDisplayName(isRTL)),
                      subtitle: Text(
                        role.getDescription(isRTL),
                        style: theme.textTheme.bodySmall,
                      ),
                      value: role,
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedRole = value);
                      },
                      secondary: Icon(role.icon, color: role.color),
                    ),
                  ),

              const SizedBox(height: 48),

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
                        : const Icon(Icons.person_add),
                label: Text(isRTL ? 'إضافة المستخدم' : 'Add User'),
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
