part of 're_active_shipment_bloc.dart';

sealed class ReActiveShipmentEvent extends Equatable {
  const ReActiveShipmentEvent();

  @override
  List<Object> get props => [];
}

class ReActiveShipmentButtonPressed extends ReActiveShipmentEvent {
  final int shipment;
  ReActiveShipmentButtonPressed(this.shipment);
}
