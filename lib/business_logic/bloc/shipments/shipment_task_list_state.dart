part of 'shipment_task_list_bloc.dart';

sealed class ShipmentTaskListState extends Equatable {
  const ShipmentTaskListState();

  @override
  List<Object> get props => [];
}

final class ShipmentTaskListInitial extends ShipmentTaskListState {}

class ShipmentRunningLoadingProgress extends ShipmentTaskListState {}

class ShipmentTaskListLoadedSuccess extends ShipmentTaskListState {
  final List<SubShipment> shipments;

  const ShipmentTaskListLoadedSuccess(this.shipments);
}

class ShipmentTaskListLoadedFailed extends ShipmentTaskListState {
  final String error;

  const ShipmentTaskListLoadedFailed(this.error);
}
