part of 'shipment_complete_list_bloc.dart';

sealed class ShipmentCompleteListState extends Equatable {
  const ShipmentCompleteListState();

  @override
  List<Object> get props => [];
}

final class ShipmentCompleteListInitial extends ShipmentCompleteListState {}

class ShipmentCompleteListLoadingProgress extends ShipmentCompleteListState {}

class ShipmentCompleteListLoadedSuccess extends ShipmentCompleteListState {
  final List<Shipmentv2> shipments;

  const ShipmentCompleteListLoadedSuccess(this.shipments);
}

class ShipmentCompleteListLoadedFailed extends ShipmentCompleteListState {
  final String error;

  const ShipmentCompleteListLoadedFailed(this.error);
}
