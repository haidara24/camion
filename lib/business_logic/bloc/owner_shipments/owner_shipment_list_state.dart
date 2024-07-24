part of 'owner_shipment_list_bloc.dart';

sealed class OwnerShipmentListState extends Equatable {
  const OwnerShipmentListState();

  @override
  List<Object> get props => [];
}

final class OwnerShipmentListInitial extends OwnerShipmentListState {}

class OwnerShipmentListLoadingProgress extends OwnerShipmentListState {}

class OwnerShipmentListLoadedSuccess extends OwnerShipmentListState {
  final List<OwnerSubShipment> shipments;

  const OwnerShipmentListLoadedSuccess(this.shipments);
}

class OwnerShipmentListLoadedFailed extends OwnerShipmentListState {
  final String error;

  const OwnerShipmentListLoadedFailed(this.error);
}
