part of 'leave_shipment_public_bloc.dart';

sealed class LeaveShipmentPublicState extends Equatable {
  const LeaveShipmentPublicState();

  @override
  List<Object> get props => [];
}

final class LeaveShipmentPublicInitial extends LeaveShipmentPublicState {}

class LeaveShipmentPublicLoadingProgressState
    extends LeaveShipmentPublicState {}

class LeaveShipmentPublicSuccessState extends LeaveShipmentPublicState {
  final bool sucess;

  LeaveShipmentPublicSuccessState(this.sucess);
}

class LeaveShipmentPublicErrorState extends LeaveShipmentPublicState {
  final String? error;
  const LeaveShipmentPublicErrorState(this.error);
}

class LeaveShipmentPublicFailureState extends LeaveShipmentPublicState {
  final String errorMessage;

  const LeaveShipmentPublicFailureState(this.errorMessage);
}
