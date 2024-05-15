part of 'active_shipment_list_bloc.dart';

sealed class ActiveShipmentListState extends Equatable {
  const ActiveShipmentListState();

  @override
  List<Object> get props => [];
}

final class ActiveShipmentListInitial extends ActiveShipmentListState {}

class ActiveShipmentListLoadingProgress extends ActiveShipmentListState {}

class ActiveShipmentListLoadedSuccess extends ActiveShipmentListState {
  final List<SubShipment> shipments;

  const ActiveShipmentListLoadedSuccess(this.shipments);
}

class ActiveShipmentListLoadedFailed extends ActiveShipmentListState {
  final String error;

  const ActiveShipmentListLoadedFailed(this.error);
}
