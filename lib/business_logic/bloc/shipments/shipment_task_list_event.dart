part of 'shipment_task_list_bloc.dart';

sealed class ShipmentTaskListEvent extends Equatable {
  const ShipmentTaskListEvent();

  @override
  List<Object> get props => [];
}

class ShipmentTaskListLoadEvent extends ShipmentTaskListEvent {}
