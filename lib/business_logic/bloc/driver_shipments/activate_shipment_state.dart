part of 'activate_shipment_bloc.dart';

sealed class ActivateShipmentState extends Equatable {
  const ActivateShipmentState();

  @override
  List<Object> get props => [];
}

final class ActivateShipmentInitial extends ActivateShipmentState {}

class ActivateShipmentLoadingProgress extends ActivateShipmentState {}

class ActivateShipmentLoadedSuccess extends ActivateShipmentState {
  final String details;

  const ActivateShipmentLoadedSuccess(this.details);
}

class ActivateShipmentLoadedFailed extends ActivateShipmentState {
  final String error;

  const ActivateShipmentLoadedFailed(this.error);
}
