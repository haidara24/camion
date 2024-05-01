part of 'shipment_running_bloc.dart';

class ShipmentRunningState extends Equatable {
  const ShipmentRunningState();

  @override
  List<Object> get props => [];
}

class ShipmentRunningInitial extends ShipmentRunningState {}

class ShipmentRunningLoadingProgress extends ShipmentRunningState {}

class ShipmentRunningLoadedSuccess extends ShipmentRunningState {
  final List<Shipmentv2> shipments;

  const ShipmentRunningLoadedSuccess(this.shipments);
}

class ShipmentRunningLoadedFailed extends ShipmentRunningState {
  final String error;

  const ShipmentRunningLoadedFailed(this.error);
}
