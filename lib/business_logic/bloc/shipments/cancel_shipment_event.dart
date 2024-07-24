part of 'cancel_shipment_bloc.dart';

sealed class CancelShipmentEvent extends Equatable {
  const CancelShipmentEvent();

  @override
  List<Object> get props => [];
}

class CancelShipmentButtonPressed extends CancelShipmentEvent {
  final int shipment;
  CancelShipmentButtonPressed(this.shipment);
}
