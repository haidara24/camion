part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignUpButtonPressed extends AuthEvent {
  final String first_name;
  final String last_name;
  final String phone;

  const SignUpButtonPressed(this.first_name, this.last_name, this.phone);
}

class PhoneSignInButtonPressed extends AuthEvent {
  final String phone;

  const PhoneSignInButtonPressed(this.phone);
}

class VerifyButtonPressed extends AuthEvent {
  final String otp;

  const VerifyButtonPressed(this.otp);
}

class UserLoggedOut extends AuthEvent {}
