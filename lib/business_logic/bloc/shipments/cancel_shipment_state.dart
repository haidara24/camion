part of 'cancel_shipment_bloc.dart';

sealed class CancelShipmentState extends Equatable {
  const CancelShipmentState();

  @override
  List<Object> get props => [];
}

final class CancelShipmentInitial extends CancelShipmentState {}

class ShippmentLoadingProgressState extends CancelShipmentState {}

class CancelShipmentSuccessState extends CancelShipmentState {}

class CancelShipmentErrorState extends CancelShipmentState {
  final String? error;
  const CancelShipmentErrorState(this.error);
}

class CancelShipmentFailureState extends CancelShipmentState {
  final String errorMessage;

  const CancelShipmentFailureState(this.errorMessage);
}
