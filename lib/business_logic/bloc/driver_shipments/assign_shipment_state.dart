part of 'assign_shipment_bloc.dart';

sealed class AssignShipmentState extends Equatable {
  const AssignShipmentState();

  @override
  List<Object> get props => [];
}

final class AssignShipmentInitial extends AssignShipmentState {}

class AssignShipmentLoadingProgressState extends AssignShipmentState {}

class AssignShipmentSuccessState extends AssignShipmentState {
  // final Shipment shipment;

  // AssignShipmentSuccessState(this.shipment);
}

class AssignShipmentErrorState extends AssignShipmentState {
  final String? error;
  const AssignShipmentErrorState(this.error);
}

class AssignShipmentFailureState extends AssignShipmentState {
  final String errorMessage;

  const AssignShipmentFailureState(this.errorMessage);
}
