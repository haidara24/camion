part of 'complete_sub_shipment_bloc.dart';

sealed class CompleteSubShipmentEvent extends Equatable {
  const CompleteSubShipmentEvent();

  @override
  List<Object> get props => [];
}

class CompleteSubShipmentButtonPressed extends CompleteSubShipmentEvent {
  final int shipment;
  CompleteSubShipmentButtonPressed(this.shipment);
}
