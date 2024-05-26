part of 'incoming_shipments_bloc.dart';

sealed class IncomingShipmentsState extends Equatable {
  const IncomingShipmentsState();

  @override
  List<Object> get props => [];
}

final class IncomingShipmentsInitial extends IncomingShipmentsState {}

class IncomingShipmentsLoadingProgress extends IncomingShipmentsState {}

class IncomingShipmentsLoadedSuccess extends IncomingShipmentsState {
  final List<SubShipment> shipments;

  const IncomingShipmentsLoadedSuccess(this.shipments);
}

class IncomingShipmentsLoadedFailed extends IncomingShipmentsState {
  final String error;

  const IncomingShipmentsLoadedFailed(this.error);
}
