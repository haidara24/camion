part of 'unassigned_shipment_list_bloc.dart';

class UnassignedShipmentListState extends Equatable {
  const UnassignedShipmentListState();

  @override
  List<Object> get props => [];
}

class UnassignedShipmentListInitial extends UnassignedShipmentListState {}

class UnassignedShipmentListLoadingProgress
    extends UnassignedShipmentListState {}

class UnassignedShipmentListLoadedSuccess extends UnassignedShipmentListState {
  final List<SubShipment> shipments;

  const UnassignedShipmentListLoadedSuccess(this.shipments);
}

class UnassignedShipmentListLoadedFailed extends UnassignedShipmentListState {
  final String error;

  const UnassignedShipmentListLoadedFailed(this.error);
}
