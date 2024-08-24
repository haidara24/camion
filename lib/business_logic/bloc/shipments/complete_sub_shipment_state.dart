part of 'complete_sub_shipment_bloc.dart';

sealed class CompleteSubShipmentState extends Equatable {
  const CompleteSubShipmentState();

  @override
  List<Object> get props => [];
}

final class CompleteSubShipmentInitial extends CompleteSubShipmentState {}

class CompleteSubShipmentLoadingProgress extends CompleteSubShipmentState {}

class CompleteSubShipmentLoadedSuccess extends CompleteSubShipmentState {}

class CompleteSubShipmentLoadedFailed extends CompleteSubShipmentState {
  final String error;

  const CompleteSubShipmentLoadedFailed(this.error);
}
