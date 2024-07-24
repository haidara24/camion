part of 'truck_active_status_bloc.dart';

sealed class TruckActiveStatusEvent extends Equatable {
  const TruckActiveStatusEvent();

  @override
  List<Object> get props => [];
}

class LoadTruckActiveStatusEvent extends TruckActiveStatusEvent {}

class UpdateTruckActiveStatusEvent extends TruckActiveStatusEvent {
  final bool status;

  UpdateTruckActiveStatusEvent(this.status);
}
