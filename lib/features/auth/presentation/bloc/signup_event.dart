// Signup Feature - BLoC Events
import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

// Personal Signup Events
class SignupPersonalRequested extends SignupEvent {
  final String name;
  final String email;
  final String password;

  const SignupPersonalRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// Business Signup Events
class SignupBusinessRequested extends SignupEvent {
  final String companyName;
  final String adminName;
  final String email;
  final String password;

  const SignupBusinessRequested({
    required this.companyName,
    required this.adminName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [companyName, adminName, email, password];
}

// Reset State
class ResetSignupState extends SignupEvent {
  const ResetSignupState();
}
