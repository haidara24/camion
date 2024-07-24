part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInButtonPressed extends AuthEvent {
  final String username;
  final String password;

  const SignInButtonPressed(this.username, this.password);
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
