part of 'inprogress_shipments_bloc.dart';

sealed class InprogressShipmentsState extends Equatable {
  const InprogressShipmentsState();

  @override
  List<Object> get props => [];
}

final class InprogressShipmentsInitial extends InprogressShipmentsState {}

class InprogressShipmentsLoadingProgress extends InprogressShipmentsState {}

class InprogressShipmentsLoadedSuccess extends InprogressShipmentsState {
  final List<SubShipment> shipments;

  const InprogressShipmentsLoadedSuccess(this.shipments);
}

class InprogressShipmentsLoadedFailed extends InprogressShipmentsState {
  final String error;

  const InprogressShipmentsLoadedFailed(this.error);
}
