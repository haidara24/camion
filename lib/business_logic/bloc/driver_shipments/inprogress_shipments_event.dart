part of 'inprogress_shipments_bloc.dart';

sealed class InprogressShipmentsEvent extends Equatable {
  const InprogressShipmentsEvent();

  @override
  List<Object> get props => [];
}

class InprogressShipmentsLoadEvent extends InprogressShipmentsEvent {
  final String state;
  final int? driverId;
  InprogressShipmentsLoadEvent(this.state, this.driverId);
}
