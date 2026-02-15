import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/login_cubit.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/login_state.dart';
import 'package:expense_tracker/features/users/presentation/cubit/user_cubit.dart';
import 'package:expense_tracker/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:expense_tracker/features/users/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/users/domain/entities/user_role.dart';
import 'package:expense_tracker/app/router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/state/user_context_manager.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_header.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_email_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_password_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_button.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/login/login_register_link.dart';
import 'package:expense_tracker/core/di/injection.dart';

/// Login screen: only triggers LoginCubit and reacts to state.
/// No service, API, or ServiceLocator access.
class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginSuccess(LoginState state, BuildContext context) async {
    final user = state.loggedInUser;
    if (user == null || !context.mounted) return;

    UserRole userRole = UserRole.owner;
    if (user.role != null && user.role!.isNotEmpty) {
      userRole = UserRole.values.firstWhere(
        (r) => r.name == user.role!.toLowerCase(),
        orElse: () => UserRole.owner,
      );
    }

    await userContextManager.onUserContextChanged(
      userId: user.id,
      role: userRole,
      companyId: user.companyId,
      context: context,
    );
    if (!context.mounted) return;

    context.read<SettingsCubit>().loadSettings(forceReload: true);
    final currentUser = UserEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      role: userRole,
      isActive: user.isActive,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLogin,
      phone: user.phone,
    );
    context.read<UserCubit>().setCurrentUser(currentUser);

    await Future.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;
    context.go(AppRoutes.home);
  }

  void _showErrorSnackBar(String message, {bool isWarning = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? AppColors.warning : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            _onLoginSuccess(state, context);
            return;
          }
          if (state.isFailure && state.errorMessage != null) {
            final msg = state.errorMessage!;
            final isEmailNotVerified = msg.contains('verify') ||
                msg.contains('تفعيل') ||
                msg.contains('verification');
            if (isEmailNotVerified) {
              _showEmailNotVerifiedSnackBar(context, msg, isRTL);
            } else {
              _showErrorSnackBar(msg);
            }
          }
        },
        builder: (context, state) {
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
                        LoginHeader(isRTL: isRTL),
                        const SizedBox(height: AppSpacing.xxxxl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXl),
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
                                  obscurePassword: !state.isPasswordVisible,
                                  onToggleVisibility: () => context
                                      .read<LoginCubit>()
                                      .togglePasswordVisibility(),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                LoginButton(
                                  isLoading: state.isLoading,
                                  isRTL: isRTL,
                                  onPressed: () {
                                    if (!_formKey.currentState!.validate()) return;
                                    context.read<LoginCubit>().login(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                LoginRegisterLink(
                                  isRTL: isRTL,
                                  onPressed: () {
                                    context.go(AppRoutes.signup);
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
        },
      ),
    );
  }

  void _showEmailNotVerifiedSnackBar(
      BuildContext context, String message, bool isRTL) {
    if (!mounted) return;
    final loginCubit = context.read<LoginCubit>();
    final email = _emailController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'يرجى تفعيل بريدك الإلكتروني أولاً' : 'Please verify your email first',
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: isRTL ? 'إعادة إرسال' : 'Resend',
          textColor: Colors.white,
          onPressed: () async {
            try {
              await loginCubit.resendVerificationEmail(email);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRTL ? 'تم إرسال رابط التفعيل' : 'Verification email sent',
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
}
