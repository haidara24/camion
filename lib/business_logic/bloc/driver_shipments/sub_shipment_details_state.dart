part of 'sub_shipment_details_bloc.dart';

sealed class SubShipmentDetailsState extends Equatable {
  const SubShipmentDetailsState();

  @override
  List<Object> get props => [];
}

final class SubShipmentDetailsInitial extends SubShipmentDetailsState {}

class SubShipmentDetailsLoadingProgress extends SubShipmentDetailsState {}

class SubShipmentDetailsLoadedSuccess extends SubShipmentDetailsState {
  final SubShipment shipment;

  const SubShipmentDetailsLoadedSuccess(this.shipment);
}

class SubShipmentDetailsLoadedFailed extends SubShipmentDetailsState {
  final String errortext;

  const SubShipmentDetailsLoadedFailed(this.errortext);
}
