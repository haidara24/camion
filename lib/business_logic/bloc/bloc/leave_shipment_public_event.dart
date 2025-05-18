part of 'leave_shipment_public_bloc.dart';

sealed class LeaveShipmentPublicEvent extends Equatable {
  const LeaveShipmentPublicEvent();

  @override
  List<Object> get props => [];
}

class LeaveShipmentPublicButtonPressed extends LeaveShipmentPublicEvent {
  final int shipment;

  LeaveShipmentPublicButtonPressed(
    this.shipment,
  );
}
