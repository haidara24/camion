part of 'driver_requests_list_bloc.dart';

sealed class DriverRequestsListEvent extends Equatable {
  const DriverRequestsListEvent();

  @override
  List<Object> get props => [];
}

class DriverRequestsListLoadEvent extends DriverRequestsListEvent {
  // final int driverId;

  const DriverRequestsListLoadEvent();
}
