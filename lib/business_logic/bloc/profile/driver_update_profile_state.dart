part of 'driver_update_profile_bloc.dart';

sealed class DriverUpdateProfileState extends Equatable {
  const DriverUpdateProfileState();

  @override
  List<Object> get props => [];
}

final class DriverUpdateProfileInitial extends DriverUpdateProfileState {}

class DriverUpdateProfileLoadingProgress extends DriverUpdateProfileState {}

class DriverUpdateProfileLoadedSuccess extends DriverUpdateProfileState {
  final int driver;

  const DriverUpdateProfileLoadedSuccess(this.driver);
}

class DriverUpdateProfileLoadedFailed extends DriverUpdateProfileState {
  final String errortext;

  const DriverUpdateProfileLoadedFailed(this.errortext);
}
