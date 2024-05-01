part of 'shipment_list_bloc.dart';

class ShipmentListState extends Equatable {
  const ShipmentListState();

  @override
  List<Object> get props => [];
}

class ShipmentListInitial extends ShipmentListState {}

class ShipmentListLoadingProgress extends ShipmentListState {}

class ShipmentListLoadedSuccess extends ShipmentListState {
  final List<Shipmentv2> shipments;

  const ShipmentListLoadedSuccess(this.shipments);
}

class ShipmentListLoadedFailed extends ShipmentListState {
  final String error;

  const ShipmentListLoadedFailed(this.error);
}
