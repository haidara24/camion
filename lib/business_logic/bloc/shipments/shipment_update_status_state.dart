part of 'shipment_update_status_bloc.dart';

sealed class ShipmentUpdateStatusState extends Equatable {
  const ShipmentUpdateStatusState();

  @override
  List<Object> get props => [];
}

final class ShipmentUpdateStatusInitial extends ShipmentUpdateStatusState {}

class ShipmentUpdateStatusLoadingProgress extends ShipmentUpdateStatusState {}

class ShipmentUpdateStatusLoadedSuccess extends ShipmentUpdateStatusState {}

class ShipmentUpdateStatusLoadedFailed extends ShipmentUpdateStatusState {
  final String errortext;

  const ShipmentUpdateStatusLoadedFailed(this.errortext);
}