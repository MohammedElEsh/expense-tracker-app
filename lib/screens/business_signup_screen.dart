import 'package:flutter/material.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/di/service_locator.dart';

/// شاشة التسجيل للحساب التجاري
class BusinessSignupScreen extends StatefulWidget {
  const BusinessSignupScreen({super.key});

  @override
  State<BusinessSignupScreen> createState() => _BusinessSignupScreenState();
}

class _BusinessSignupScreenState extends State<BusinessSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminNameController.dispose();
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
      debugPrint('🧹 مسح الوضع القديم قبل إنشاء حساب تجاري جديد...');
      await SettingsService.clearModeAndCompany();

      // 1. إنشاء حساب عبر REST API (الشركة تُنشأ على الباك إند)
      debugPrint('🔐 إنشاء حساب تجاري...');
      final authResponse = await serviceLocator.authRemoteDataSource.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _adminNameController.text.trim(),
        accountType: 'business',
        companyName: _companyNameController.text.trim(),
      );

      final user = authResponse.user;
      final userId = user.id;
      final companyId = user.companyId;

      debugPrint('✅ تم إنشاء حساب المدير: $userId');
      debugPrint('🏢 معرف الشركة: $companyId');

      // 2. حفظ الوضع التجاري فورًا قبل تسجيل الخروج
      debugPrint('💾 حفظ الوضع التجاري...');
      await SettingsService.setAppMode(AppMode.business);
      if (companyId != null) {
        await SettingsService.setCompanyId(companyId);
      }
      debugPrint('✅ تم حفظ الوضع: business mode مع companyId: $companyId');

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
                  ? 'تم إنشاء الحساب التجاري بنجاح! الرجاء تسجيل الدخول.'
                  : 'Business account created successfully! Please login.',
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
        title: Text(isRTL ? 'إنشاء حساب تجاري' : 'Create Business Account'),
        backgroundColor: Colors.blue,
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
                Icon(Icons.business, size: 64, color: theme.primaryColor),
                const SizedBox(height: 16),
                Text(
                  isRTL
                      ? 'أنشئ حساب شركتك واحصل على صلاحيات المدير العام'
                      : 'Create your company account and get full admin access',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Company Information Section
                Text(
                  isRTL ? 'معلومات الشركة' : 'Company Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Company Name
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'اسم الشركة' : 'Company Name',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isRTL ? 'أدخل اسم الشركة' : 'Enter company name';
                    }
                    if (value.trim().length < 3) {
                      return isRTL
                          ? 'اسم الشركة يجب أن يكون 3 أحرف على الأقل'
                          : 'Company name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Admin Information Section
                Text(
                  isRTL ? 'معلومات المدير العام' : 'Admin Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Admin Name
                TextFormField(
                  controller: _adminNameController,
                  decoration: InputDecoration(
                    labelText: isRTL ? 'اسم المدير' : 'Admin Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isRTL ? 'أدخل اسم المدير' : 'Enter admin name';
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
                      backgroundColor: Colors.blue,
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
