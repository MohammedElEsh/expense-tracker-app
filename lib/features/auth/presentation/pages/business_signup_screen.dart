// ✅ Business Signup Screen - Refactored with BLoC
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/signup_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/signup_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/signup_state.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/company_name_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/name_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/email_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/password_field.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/signup_button.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/signup_header.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/signup/login_redirect.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_screen.dart';

/// شاشة التسجيل للحساب التجاري - Refactored
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

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup(BuildContext context, bool isRTL) {
    if (!_formKey.currentState!.validate()) return;

    context.read<SignupBloc>().add(
      SignupBusinessRequested(
        companyName: _companyNameController.text.trim(),
        adminName: _adminNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => SignupBloc(),
      child: BlocConsumer<SignupBloc, SignupState>(
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
                      ? 'تم إنشاء الحساب التجاري بنجاح! الرجاء تسجيل الدخول.'
                      : state.successMessage ??
                          'Business account created successfully!',
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
                isRTL ? 'إنشاء حساب تجاري' : 'Create Business Account',
              ),
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
                      SignupHeader(
                        isRTL: isRTL,
                        isBusinessMode: true,
                        primaryColor: theme.primaryColor,
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
                      CompanyNameField(
                        controller: _companyNameController,
                        isRTL: isRTL,
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
                      NameField(
                        controller: _adminNameController,
                        isRTL: isRTL,
                        label: isRTL ? 'اسم المدير' : 'Admin Name',
                        icon: Icons.person,
                      ),
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
                        isBusinessMode: true,
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
