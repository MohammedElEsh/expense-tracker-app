import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_service.dart';
import 'package:expense_tracker/features/users/data/models/user.dart';
import 'package:expense_tracker/features/app_mode/data/models/app_mode.dart';
import 'package:expense_tracker/app/pages/main_screen.dart';
import 'package:expense_tracker/features/auth/presentation/pages/signup_screen.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_header.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_email_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_password_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_button.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_register_link.dart';

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

      // تحديث حالة المستخدم في Cubit
      if (mounted) {
        // تحديث SettingsCubit بالوضع الجديد - Force reload to refresh appMode/companyId
        context.read<SettingsCubit>().loadSettings(forceReload: true);

        // Parse role from API response (defaults to owner if not provided)
        UserRole userRole = UserRole.owner;
        if (user.role != null && user.role!.isNotEmpty) {
          try {
            userRole = UserRole.values.firstWhere(
              (role) => role.name == user.role!.toLowerCase(),
              orElse: () => UserRole.owner,
            );
          } catch (e) {
            debugPrint(
              '⚠️ Invalid role from API: ${user.role}, defaulting to owner',
            );
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

        // تحديث UserCubit
        context.read<UserCubit>().setCurrentUser(currentUser);

        // ⏳ انتظار تحديث الـ Cubit قبل الـ navigation
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('✅ تم تحديث UserCubit');

        // الانتقال إلى الشاشة الرئيسية
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on AccountDeactivatedException catch (e) {
      _showDeactivatedError(e);
    } on EmailNotVerifiedException catch (e) {
      _showEmailNotVerifiedError(e);
    } on AuthException catch (e) {
      _showAuthError(e);
    } catch (error) {
      _showGenericError(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeactivatedError(AccountDeactivatedException e) {
    if (!mounted) return;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.block,
              color: Colors.white,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRTL ? 'الحساب معطل' : 'Account Deactivated',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(e.message),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _showEmailNotVerifiedError(EmailNotVerifiedException e) {
    if (!mounted) return;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'يرجى تفعيل بريدك الإلكتروني أولاً'
              : 'Please verify your email first',
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: isRTL ? 'إعادة إرسال' : 'Resend',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await serviceLocator.authRemoteDataSource.resendVerificationEmail(
                e.email,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL
                          ? 'تم إرسال رابط التفعيل'
                          : 'Verification email sent',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } catch (_) {}
          },
        ),
      ),
    );
  }

  void _showAuthError(AuthException e) {
    if (!mounted) return;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRTL ? 'خطأ في تسجيل الدخول: ${e.message}' : e.message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGenericError(Object error) {
    if (!mounted) return;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'خطأ في تسجيل الدخول: $error' : 'Login error: $error',
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Title
                  LoginHeader(isRTL: isRTL),
                  const SizedBox(height: AppSpacing.xxxxl),

                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          LoginEmailField(
                            controller: _emailController,
                            isRTL: isRTL,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LoginPasswordField(
                            controller: _passwordController,
                            isRTL: isRTL,
                            obscurePassword: _obscurePassword,
                            onToggleVisibility: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          LoginButton(
                            isLoading: _isLoading,
                            isRTL: isRTL,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          LoginRegisterLink(
                            isRTL: isRTL,
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                              );
                            },
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
