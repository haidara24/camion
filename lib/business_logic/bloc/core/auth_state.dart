part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthInProgressState extends AuthState {}

class AuthLoggingInProgressState extends AuthState {}

class AuthRegisteringProgressState extends AuthState {}

class AuthResgisteringSuccess extends AuthState {}

class PhoneAuthSuccessState extends AuthState {
  final dynamic data;

  PhoneAuthSuccessState(this.data);
}

class PhoneAuthFailedState extends AuthState {
  final String? error;

  PhoneAuthFailedState(this.error);
}

// class AuthActivateLoadingState extends AuthState {}

class AuthDriverSuccessState extends AuthState {}

class AuthOwnerSuccessState extends AuthState {}

class AuthMerchantSuccessState extends AuthState {}

class AuthManagmentSuccessState extends AuthState {}

class AuthCheckPointSuccessState extends AuthState {}

class AuthLoginErrorState extends AuthState {
  final String? error;
  const AuthLoginErrorState(this.error);
}

class AuthFailureState extends AuthState {
  final String errorMessage;

  const AuthFailureState(this.errorMessage);
}
