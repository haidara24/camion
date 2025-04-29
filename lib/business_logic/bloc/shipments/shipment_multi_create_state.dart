part of 'shipment_multi_create_bloc.dart';

sealed class ShipmentMultiCreateState extends Equatable {
  const ShipmentMultiCreateState();

  @override
  List<Object> get props => [];
}

final class ShipmentMultiCreateInitial extends ShipmentMultiCreateState {}

class ShippmentLoadingProgressState extends ShipmentMultiCreateState {}

class ShipmentMultiCreateSuccessState extends ShipmentMultiCreateState {
  final Shipmentv2? shipment;

  ShipmentMultiCreateSuccessState(this.shipment);
}

class ShipmentMultiCreateErrorState extends ShipmentMultiCreateState {
  final String? error;
  const ShipmentMultiCreateErrorState(this.error);
}

class ShipmentMultiCreateFailureState extends ShipmentMultiCreateState {
  final String errorMessage;

  const ShipmentMultiCreateFailureState(this.errorMessage);
}
