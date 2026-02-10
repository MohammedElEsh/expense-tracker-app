import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// شاشة التسجيل للحساب الشخصي
class PersonalSignupScreen extends StatefulWidget {
  const PersonalSignupScreen({super.key});

  @override
  State<PersonalSignupScreen> createState() => _PersonalSignupScreenState();
}

class _PersonalSignupScreenState extends State<PersonalSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isRTL = Directionality.of(context) == TextDirection.rtl;

      // 🔥 مسح الوضع القديم قبل إنشاء الحساب
      debugPrint('🧹 مسح الوضع القديم قبل إنشاء حساب شخصي جديد...');
      await SettingsService.clearModeAndCompany();

      // 1. إنشاء حساب عبر REST API
      final authResponse = await serviceLocator.authRemoteDataSource.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        accountType: 'personal',
      );

      final userId = authResponse.user.id;
      debugPrint('✅ تم إنشاء مستخدم شخصي: $userId');

      // 2. حفظ الوضع الشخصي فورًا قبل تسجيل الخروج
      debugPrint('💾 حفظ الوضع الشخصي...');
      await SettingsService.setAppMode(AppMode.personal);
      await SettingsService.setCompanyId(null);
      debugPrint('✅ تم حفظ الوضع: personal mode');

      // 3. تسجيل خروج لإجبار المستخدم على تسجيل الدخول من جديد
      debugPrint('🚪 تسجيل خروج لإعادة تسجيل الدخول...');
      await serviceLocator.authRemoteDataSource.logout();

      // 4. الانتقال إلى شاشة تسجيل الدخول
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SimpleLoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL
                  ? 'تم إنشاء الحساب الشخصي بنجاح! الرجاء تسجيل الدخول.'
                  : 'Personal account created successfully! Please login.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'خطأ في إنشاء الحساب: ${e.message}' : e.message,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL
                  ? 'خطأ في إنشاء الحساب: $error'
                  : 'Error creating account: $error',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isRTL ? 'إنشاء حساب شخصي' : 'Create Personal Account'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(Icons.person, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  isRTL
                      ? 'أنشئ حسابك الشخصي وابدأ في تتبع مصروفاتك'
                      : 'Create your personal account and start tracking expenses',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'الاسم' : 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isRTL ? 'أدخل الاسم' : 'Enter name';
                    }
                    if (value.trim().length < 3) {
                      return isRTL
                          ? 'الاسم يجب أن يكون 3 أحرف على الأقل'
                          : 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'البريد الإلكتروني' : 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isRTL ? 'أدخل البريد الإلكتروني' : 'Enter email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return isRTL
                          ? 'أدخل بريد إلكتروني صحيح'
                          : 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'كلمة المرور' : 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return isRTL ? 'أدخل كلمة المرور' : 'Enter password';
                    }
                    if (value.length < 6) {
                      return isRTL
                          ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                          : 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'تأكيد كلمة المرور' : 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return isRTL
                          ? 'كلمة المرور غير متطابقة'
                          : 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Signup Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              isRTL ? 'إنشاء الحساب' : 'Create Account',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
