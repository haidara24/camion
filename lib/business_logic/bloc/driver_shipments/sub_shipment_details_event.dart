part of 'sub_shipment_details_bloc.dart';

sealed class SubShipmentDetailsEvent extends Equatable {
  const SubShipmentDetailsEvent();

  @override
  List<Object> get props => [];
}

class SubShipmentDetailsLoadEvent extends SubShipmentDetailsEvent {
  final int id;

  SubShipmentDetailsLoadEvent(this.id);
}
