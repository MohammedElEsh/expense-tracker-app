// ✅ Personal Signup Screen - Refactored with Cubit
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/signup_cubit.dart';
import 'package:expense_tracker/features/auth/presentation/cubit/signup_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/name_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/email_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/password_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/signup_button.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/signup_header.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/login_redirect.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';

/// شاشة التسجيل للحساب الشخصي - Refactored
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context, bool isRTL) {
    if (!_formKey.currentState!.validate()) return;

    context.read<SignupCubit>().signupPersonal(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (context) => SignupCubit(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.isSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SimpleLoginScreen(),
              ),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isRTL
                      ? 'تم إنشاء الحساب الشخصي بنجاح! الرجاء تسجيل الدخول.'
                      : state.successMessage ??
                          'Personal account created successfully!',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.fixed,
                duration: const Duration(seconds: 4),
              ),
            );
          }

          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isRTL
                      ? 'خطأ في إنشاء الحساب: ${state.errorMessage}'
                      : state.errorMessage ?? 'Error creating account',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.fixed,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                isRTL ? 'إنشاء حساب شخصي' : 'Create Personal Account',
              ),
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
                      SignupHeader(
                        isRTL: isRTL,
                        isBusinessMode: false,
                        primaryColor: Colors.green,
                      ),
                      const SizedBox(height: 32),

                      // Name
                      NameField(controller: _nameController, isRTL: isRTL),
                      const SizedBox(height: 16),

                      // Email
                      EmailField(controller: _emailController, isRTL: isRTL),
                      const SizedBox(height: 16),

                      // Password
                      PasswordField(
                        controller: _passwordController,
                        isRTL: isRTL,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      PasswordField(
                        controller: _confirmPasswordController,
                        isRTL: isRTL,
                        isConfirmPassword: true,
                        passwordToMatch: _passwordController,
                      ),
                      const SizedBox(height: 32),

                      // Signup Button
                      SignupButton(
                        isLoading: state.isLoading,
                        isRTL: isRTL,
                        isBusinessMode: false,
                        onPressed: () => _handleSignup(context, isRTL),
                      ),
                      const SizedBox(height: 16),

                      // Login Redirect
                      LoginRedirect(
                        isRTL: isRTL,
                        onLoginPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const SimpleLoginScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
