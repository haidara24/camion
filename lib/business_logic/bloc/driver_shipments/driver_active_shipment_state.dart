part of 'driver_active_shipment_bloc.dart';

sealed class DriverActiveShipmentState extends Equatable {
  const DriverActiveShipmentState();

  @override
  List<Object> get props => [];
}

final class DriverActiveShipmentInitial extends DriverActiveShipmentState {}

class DriverActiveShipmentLoadingProgress extends DriverActiveShipmentState {}

class DriverActiveShipmentLoadedSuccess extends DriverActiveShipmentState {
  final List<SubShipment> shipments;

  const DriverActiveShipmentLoadedSuccess(this.shipments);
}

class DriverActiveShipmentLoadedFailed extends DriverActiveShipmentState {
  final String error;

  const DriverActiveShipmentLoadedFailed(this.error);
}
