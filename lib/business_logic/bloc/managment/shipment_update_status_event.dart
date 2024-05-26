part of 'shipment_update_status_bloc.dart';

sealed class ShipmentUpdateStatusEvent extends Equatable {
  const ShipmentUpdateStatusEvent();

  @override
  List<Object> get props => [];
}

class ShipmentStatusUpdateEvent extends ShipmentUpdateStatusEvent {
  final int shipmentId;
  final String state;

  const ShipmentStatusUpdateEvent(this.shipmentId, this.state);
}
