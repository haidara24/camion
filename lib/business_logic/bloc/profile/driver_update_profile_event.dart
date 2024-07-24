part of 'driver_update_profile_bloc.dart';

sealed class DriverUpdateProfileEvent extends Equatable {
  const DriverUpdateProfileEvent();

  @override
  List<Object> get props => [];
}

class DriverUpdateProfileButtonPressed extends DriverUpdateProfileEvent {
  final Driver driver;
  final File? file;
  DriverUpdateProfileButtonPressed(this.driver, this.file);
}
