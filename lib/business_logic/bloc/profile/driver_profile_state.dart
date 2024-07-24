part of 'driver_profile_bloc.dart';

sealed class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object> get props => [];
}

final class DriverProfileInitial extends DriverProfileState {}

class DriverProfileLoadingProgress extends DriverProfileState {}

class DriverProfileLoadedSuccess extends DriverProfileState {
  final Driver driver;

  const DriverProfileLoadedSuccess(this.driver);
}

class DriverProfileLoadedFailed extends DriverProfileState {
  final String errortext;

  const DriverProfileLoadedFailed(this.errortext);
}
