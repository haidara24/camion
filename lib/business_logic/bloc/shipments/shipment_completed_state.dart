part of 'shipment_completed_bloc.dart';

class ShipmentCompletedState extends Equatable {
  const ShipmentCompletedState();

  @override
  List<Object> get props => [];
}

class ShipmentCompletedInitial extends ShipmentCompletedState {}

class ShipmentCompletedLoadingProgress extends ShipmentCompletedState {}

class ShipmentCompletedLoadedSuccess extends ShipmentCompletedState {
  final List<Shipmentv2> shipments;

  const ShipmentCompletedLoadedSuccess(this.shipments);
}

class ShipmentCompletedLoadedFailed extends ShipmentCompletedState {
  final String error;

  const ShipmentCompletedLoadedFailed(this.error);
}
