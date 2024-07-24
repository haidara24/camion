part of 'owner_active_shipments_bloc.dart';

sealed class OwnerActiveShipmentsState extends Equatable {
  const OwnerActiveShipmentsState();

  @override
  List<Object> get props => [];
}

final class OwnerActiveShipmentsInitial extends OwnerActiveShipmentsState {}

class OwnerActiveShipmentsLoadingProgress extends OwnerActiveShipmentsState {}

class OwnerActiveShipmentsLoadedSuccess extends OwnerActiveShipmentsState {
  final List<OwnerSubShipment> shipments;

  const OwnerActiveShipmentsLoadedSuccess(this.shipments);
}

class OwnerActiveShipmentsLoadedFailed extends OwnerActiveShipmentsState {
  final String error;

  const OwnerActiveShipmentsLoadedFailed(this.error);
}
