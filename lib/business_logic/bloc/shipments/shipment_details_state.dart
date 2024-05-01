part of 'shipment_details_bloc.dart';

sealed class ShipmentDetailsState extends Equatable {
  const ShipmentDetailsState();

  @override
  List<Object> get props => [];
}

final class ShipmentDetailsInitial extends ShipmentDetailsState {}

class ShipmentDetailsLoadingProgress extends ShipmentDetailsState {}

class ShipmentDetailsLoadedSuccess extends ShipmentDetailsState {
  final Shipmentv2 shipment;

  const ShipmentDetailsLoadedSuccess(this.shipment);
}

class ShipmentDetailsLoadedFailed extends ShipmentDetailsState {
  final String errortext;

  const ShipmentDetailsLoadedFailed(this.errortext);
}
