import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_bloc.dart';
import 'package:expense_tracker/features/users/presentation/bloc/user_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/screens/main_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_screen.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';

/// شاشة تسجيل الدخول البسيطة
class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isRTL = Directionality.of(context) == TextDirection.rtl;

      // تسجيل الدخول باستخدام REST API
      final authResponse = await serviceLocator.authRemoteDataSource.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = authResponse.user;
      final userId = user.id;
      final email = user.email;
      final displayName = user.name;

      debugPrint('✅ تم تسجيل الدخول بنجاح: $email');

      // ضبط الوضع بناءً على accountType
      final accountType = user.accountType;
      debugPrint('📊 نوع الحساب: $accountType');

      if (accountType == 'business') {
        final companyId = user.companyId;
        debugPrint('🏢 معرف الشركة: $companyId');

        if (companyId == null || companyId.isEmpty) {
          throw Exception(
            isRTL ? 'معرف الشركة غير موجود' : 'Company ID not found',
          );
        }

        await SettingsService.setAppMode(AppMode.business);
        await SettingsService.setCompanyId(companyId);
        debugPrint('✅ ضبط الوضع: business mode مع companyId: $companyId');
      } else {
        await SettingsService.setAppMode(AppMode.personal);
        await SettingsService.setCompanyId(null);
        debugPrint('✅ ضبط الوضع: personal mode');
      }

      // انتظار إضافي للتأكد من حفظ البيانات
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('✅ تم حفظ البيانات في SettingsService');

      // تحديث حالة المستخدم في BLoC
      if (mounted) {
        // تحديث SettingsBloc بالوضع الجديد - Force reload to refresh appMode/companyId
        context.read<SettingsBloc>().add(const LoadSettings(forceReload: true));

        // Parse role from API response (defaults to owner if not provided)
        UserRole userRole = UserRole.owner;
        if (user.role != null && user.role!.isNotEmpty) {
          try {
            userRole = UserRole.values.firstWhere(
              (role) => role.name == user.role!.toLowerCase(),
              orElse: () => UserRole.owner,
            );
          } catch (e) {
            debugPrint('⚠️ Invalid role from API: ${user.role}, defaulting to owner');
            userRole = UserRole.owner;
          }
        }

        debugPrint('👤 User role from API: ${user.role} -> ${userRole.name}');

        // Clear state BEFORE setting new user (to prevent data leakage)
        await userContextManager.onUserContextChanged(
          userId: userId,
          role: userRole,
          companyId: user.companyId,
          context: context,
        );

        // إنشاء كائن المستخدم
        final currentUser = User(
          id: userId,
          name: displayName,
          email: email,
          role: userRole,
          department: null,
          isActive: user.isActive,
          createdAt: user.createdAt ?? DateTime.now(),
        );

        // تحديث UserBloc
        context.read<UserBloc>().add(SetCurrentUser(currentUser));

        // ⏳ انتظار تحديث الـ BLoC قبل الـ navigation
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('✅ تم تحديث UserBloc');

        // الانتقال إلى الشاشة الرئيسية
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on AccountDeactivatedException catch (e) {
      // معالجة خاصة للحسابات المعطلة
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? 'الحساب معطل' : 'Account Deactivated',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(e.message),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on EmailNotVerifiedException catch (e) {
      // معالجة البريد غير المفعل
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL
                  ? 'يرجى تفعيل بريدك الإلكتروني أولاً'
                  : 'Please verify your email first',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: isRTL ? 'إعادة إرسال' : 'Resend',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  // Fixed: Use serviceLocator instead of static call
                  await serviceLocator.authRemoteDataSource
                      .resendVerificationEmail(e.email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isRTL
                              ? 'تم إرسال رابط التفعيل'
                              : 'Verification email sent',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (_) {}
              },
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'خطأ في تسجيل الدخول: ${e.message}' : e.message,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final isRTL = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRTL ? 'خطأ في تسجيل الدخول: $error' : 'Login error: $error',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRTL ? 'متتبع المصروفات' : 'Expense Tracker',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRTL ? 'سجل دخولك للمتابعة' : 'Login to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                                return isRTL
                                    ? 'أدخل البريد الإلكتروني'
                                    : 'Enter email';
                              }
                              if (!value.contains('@')) {
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
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return isRTL
                                    ? 'أدخل كلمة المرور'
                                    : 'Enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        isRTL ? 'تسجيل الدخول' : 'Login',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Create Account
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                              );
                            },
                            child: Text(
                              isRTL
                                  ? 'ليس لديك حساب؟ أنشئ حساب جديد'
                                  : "Don't have an account? Create one",
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
