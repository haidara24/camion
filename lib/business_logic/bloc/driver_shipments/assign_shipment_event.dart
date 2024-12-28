part of 'assign_shipment_bloc.dart';

sealed class AssignShipmentEvent extends Equatable {
  const AssignShipmentEvent();

  @override
  List<Object> get props => [];
}

class AssignShipmentButtonPressed extends AssignShipmentEvent {
  final int driver;
  final int shipment;

  AssignShipmentButtonPressed(this.shipment, this.driver);
}
