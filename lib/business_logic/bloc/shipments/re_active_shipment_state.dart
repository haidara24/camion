part of 're_active_shipment_bloc.dart';

sealed class ReActiveShipmentState extends Equatable {
  const ReActiveShipmentState();

  @override
  List<Object> get props => [];
}

final class ReActiveShipmentInitial extends ReActiveShipmentState {}

class ReActiveShippmentLoadingProgressState extends ReActiveShipmentState {}

class ReActiveShipmentSuccessState extends ReActiveShipmentState {}

class ReActiveShipmentErrorState extends ReActiveShipmentState {
  final String? error;
  const ReActiveShipmentErrorState(this.error);
}

class ReActiveShipmentFailureState extends ReActiveShipmentState {
  final String errorMessage;

  const ReActiveShipmentFailureState(this.errorMessage);
}
