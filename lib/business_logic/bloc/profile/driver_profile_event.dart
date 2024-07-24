part of 'driver_profile_bloc.dart';

sealed class DriverProfileEvent extends Equatable {
  const DriverProfileEvent();

  @override
  List<Object> get props => [];
}

class DriverProfileLoad extends DriverProfileEvent {
  final int driver;

  DriverProfileLoad(this.driver);
}
