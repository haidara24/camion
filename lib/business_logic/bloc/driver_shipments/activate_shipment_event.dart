part of 'activate_shipment_bloc.dart';

sealed class ActivateShipmentEvent extends Equatable {
  const ActivateShipmentEvent();

  @override
  List<Object> get props => [];
}

class ActivateShipmentButtomPressedEvent extends ActivateShipmentEvent {
  final int shipmentId;

  ActivateShipmentButtomPressedEvent(this.shipmentId);
}
