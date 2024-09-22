part of 'owner_incoming_shipments_bloc.dart';

class OwnerIncomingShipmentsState extends Equatable {
  const OwnerIncomingShipmentsState();

  @override
  List<Object> get props => [];
}

class OwnerIncomingShipmentsInitial extends OwnerIncomingShipmentsState {}

class OwnerIncomingShipmentsLoadingProgress
    extends OwnerIncomingShipmentsState {}

class OwnerIncomingShipmentsLoadedSuccess extends OwnerIncomingShipmentsState {
  final List<ApprovalRequest> requests;

  const OwnerIncomingShipmentsLoadedSuccess(this.requests);
}

class OwnerIncomingShipmentsLoadedFailed extends OwnerIncomingShipmentsState {
  final String error;

  const OwnerIncomingShipmentsLoadedFailed(this.error);
}
